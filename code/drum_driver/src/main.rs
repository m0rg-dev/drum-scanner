#![no_std]
#![no_main]
#![feature(abi_avr_interrupt)]

use arduino_hal::{
    clock::Clock,
    hal::port::{PB0, PD2, PD5},
    pac::{tc1::tccr1b::CS1_A, TC1},
    port::{mode::Output, Pin},
    prelude::*,
};
use embedded_hal::serial::Read;
use panic_halt as _;

mod mutex;
use mutex::Mutex;

struct DeviceState {
    drum_step: Pin<Output, PD2>,
    #[allow(dead_code)]
    drum_direction: Pin<Output, PD5>,
    stepper_enable: Pin<Output, PB0>,
    drum_speed_rpm: u8,
    timer: TC1,
}

const TICKS_PER_REV: u32 = 400;
const MICROSTEPPING: u32 = 16;
const GEAR_RATIO: u32 = 5;

impl DeviceState {
    pub fn drum_command(&mut self, rpm: u8) {
        self.drum_speed_rpm = rpm;

        if self.drum_speed_rpm > 0 {
            self.stepper_enable.set_low();
            configure_timer(
                &self.timer,
                ((rpm as u32) * TICKS_PER_REV * MICROSTEPPING * GEAR_RATIO) / 60,
            );
        } else {
            self.stepper_enable.set_high();
            disable_timer(&self.timer);
            self.drum_step.set_low();
        }
    }
}

static STATE: Mutex<Option<DeviceState>> = Mutex::new(None);

#[arduino_hal::entry]
fn main() -> ! {
    let dp = arduino_hal::Peripherals::take().unwrap();
    let pins = arduino_hal::pins!(dp);
    let mut serial = arduino_hal::default_serial!(dp, pins, 57600);

    ufmt::uwriteln!(&mut serial, "initialized\r").void_unwrap();

    {
        let mut state = STATE.lock();
        *state = Some(DeviceState {
            drum_step: pins.d2.into_output(),
            drum_direction: pins.d5.into_output(),
            stepper_enable: pins.d8.into_output_high(),
            drum_speed_rpm: 0,
            timer: dp.TC1,
        });
    }

    unsafe {
        avr_device::interrupt::enable();
    }

    loop {
        let b = nb::block!(serial.read()).void_unwrap();

        ufmt::uwriteln!(&mut serial, "Got {}!\r", b).void_unwrap();

        if b == 0x31 {
            ufmt::uwriteln!(&mut serial, "start drum\r").void_unwrap();
            STATE.lock().as_mut().unwrap().drum_command(60);
        } else if b == 0x30 {
            ufmt::uwriteln!(&mut serial, "stop drum\r").void_unwrap();
            STATE.lock().as_mut().unwrap().drum_command(0);
        }
    }
}

fn configure_timer(timer: &TC1, rate_hz: u32) {
    const CLOCK_HZ: u32 = arduino_hal::DefaultClock::FREQ;

    let (prescale_bits, prescale_factor) = if rate_hz > (CLOCK_HZ / 65536) {
        (CS1_A::DIRECT, 1)
    } else if rate_hz > (CLOCK_HZ / (8 * 65536)) {
        (CS1_A::PRESCALE_8, 8)
    } else if rate_hz > (CLOCK_HZ / (64 * 65536)) {
        (CS1_A::PRESCALE_64, 64)
    } else {
        // we don't have to check PRESCALE_1024 here since 256 bottoms out at 0.95 Hz
        // and we're taking a u32 for the interrupt rate
        (CS1_A::PRESCALE_256, 256)
    };

    // TODO unwrap
    let ocr: u16 = (CLOCK_HZ / rate_hz / prescale_factor - 1)
        .try_into()
        .unwrap();

    // stop interrupts while we're messing with the timer
    avr_device::interrupt::free(|_cs| {
        timer.tccr1a.write(|w| w.wgm1().bits(0b00));
        timer
            .tccr1b
            .write(|w| w.cs1().variant(prescale_bits).wgm1().bits(0b01));
        timer.ocr1a.write(|w| unsafe { w.bits(ocr) });
        timer.timsk1.write(|w| w.ocie1a().set_bit());
    });
}

fn disable_timer(timer: &TC1) {
    // stop interrupts while we're messing with the timer
    avr_device::interrupt::free(|_cs| {
        timer.timsk1.write(|w| w.ocie1a().clear_bit());
    });
}

#[avr_device::interrupt(atmega328p)]
fn TIMER1_COMPA() {
    let state = STATE.try_lock();
    if let Some(mut state) = state {
        state.as_mut().map(|state| {
            state.drum_step.toggle();
        });
    }
}

#[no_mangle]
fn abort() -> ! {
    loop {}
}
