use core::{
    cell::UnsafeCell,
    ops::{Deref, DerefMut},
    sync::atomic,
};

use atomic::Ordering;

pub struct Mutex<T> {
    data: UnsafeCell<T>,
    lock: UnsafeCell<u8>,
}

impl<T> Mutex<T> {
    pub const fn new(t: T) -> Mutex<T> {
        Mutex {
            data: UnsafeCell::new(t),
            lock: UnsafeCell::new(0),
        }
    }

    fn is_locked(&self) -> bool {
        // Safety: u8 read/write is atomic on AVR.
        unsafe { *self.lock.get() > 0 }
    }

    pub fn lock(&self) -> MutexGuard<'_, T> {
        let mut did_we_lock = false;
        while !did_we_lock {
            // First, spin on self.lock until we read it as unlocked. This avoids unnecesarily
            // clearing interrupts while we're waiting.
            while self.is_locked() {
                atomic::compiler_fence(Ordering::SeqCst);
            }

            // Now, actually do a critical section and make darn sure *we* are who gets the
            // mutex. If we're in a critical section (interrupts disabled!) and we can read
            // self.lock as 0, that means we got it.
            avr_device::interrupt::free(|_cs| {
                if !self.is_locked() {
                    // Safety: u8 read/write is atomic on AVR, and if we got to this block
                    // it means that we read self.lock as 0 with interrups disabled, so we're
                    // allowed to lock the mutex.
                    unsafe {
                        *self.lock.get() = 1;
                    }
                    did_we_lock = true;
                }
            });
        }

        // OK, now we wrote self.lock to 1 after reading it as 0 with interrupts disabled.
        // That means we own the mutex and we can hand out a MutexGuard.

        MutexGuard::new(self)
    }

    pub fn try_lock(&self) -> Option<MutexGuard<'_, T>> {
        let mut did_we_lock = false;
        // First, check self.lock the easy way. If it's set, we definitely can't lock.
        if self.is_locked() {
            return None;
        }

        // Now, actually do a critical section and make darn sure *we* are who gets the
        // mutex. If we're in a critical section (interrupts disabled!) and we can read
        // self.lock as 0, that means we got it.
        avr_device::interrupt::free(|_cs| {
            if !self.is_locked() {
                // Safety: u8 read/write is atomic on AVR, and if we got to this block
                // it means that we read self.lock as 0 with interrups disabled, so we're
                // allowed to lock the mutex.
                unsafe {
                    *self.lock.get() = 1;
                }
                did_we_lock = true;
            }
        });

        if did_we_lock {
            // OK, now we wrote self.lock to 1 after reading it as 0 with interrupts disabled.
            // That means we own the mutex and we can hand out a MutexGuard.
            Some(MutexGuard::new(self))
        } else {
            // Someone else got there first.
            return None;
        }
    }
}

unsafe impl<T> Sync for Mutex<T> where T: Send {}

#[must_use = "if unused the Mutex will immediately unlock"]
#[clippy::has_significant_drop]
pub struct MutexGuard<'a, T: 'a> {
    lock: &'a Mutex<T>,
}

impl<'mutex, T> MutexGuard<'mutex, T> {
    fn new(lock: &'mutex Mutex<T>) -> MutexGuard<'mutex, T> {
        MutexGuard { lock }
    }
}

impl<'mutex, T> Drop for MutexGuard<'mutex, T> {
    fn drop(&mut self) {
        unsafe {
            // Safety: u8 read/write is atomic on AVR, and since we are a MutexGuard,
            // we're allowed to do whatever we like with the Mutex.
            *self.lock.lock.get() = 0;
        }
    }
}

impl<T> Deref for MutexGuard<'_, T> {
    type Target = T;

    fn deref(&self) -> &T {
        unsafe { &*self.lock.data.get() }
    }
}

impl<T> DerefMut for MutexGuard<'_, T> {
    fn deref_mut(&mut self) -> &mut T {
        unsafe { &mut *self.lock.data.get() }
    }
}
