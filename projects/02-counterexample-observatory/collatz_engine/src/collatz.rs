use serde::{Deserialize, Serialize};
use std::time::Instant;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordStoppingTime {
    pub start_n: u64,
    pub stopping_time: u32,
    pub peak_height: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecordPeakHeight {
    pub start_n: u64,
    pub peak_height: u64,
    pub stopping_time: u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CollatzRunStats {
    pub limit_n: u64,
    pub total_numbers_checked: u64,
    pub max_stopping_time_found: u32,
    pub max_stopping_time_champion: u64,
    pub max_peak_height_found: u64,
    pub max_peak_height_champion: u64,
    pub count_stopping_time_records: usize,
    pub count_peak_height_records: usize,
    pub counterexamples_found: u64,
    pub stopping_time_records: Vec<RecordStoppingTime>,
    pub peak_height_records: Vec<RecordPeakHeight>,
    pub execution_time_ms: u128,
}

pub struct CollatzEngine {
    pub limit: u64,
    pub cache_size: usize,
    pub cache: Vec<u16>,
}

impl CollatzEngine {
    pub fn new(limit: u64, cache_size: usize) -> Self {
        Self {
            limit,
            cache_size,
            cache: vec![0u16; cache_size],
        }
    }

    pub fn run(&mut self) -> CollatzRunStats {
        let start_time = Instant::now();

        let mut max_stopping_time = 0u32;
        let mut max_stopping_champ = 1u64;
        let mut stopping_records = Vec::new();

        let mut max_peak = 0u64;
        let mut max_peak_champ = 1u64;
        let mut peak_records = Vec::new();

        let mut stack = Vec::with_capacity(512);

        for n in 1..=self.limit {
            let mut curr = n;
            let mut steps = 0u32;
            let mut local_peak = n;
            stack.clear();

            while curr > 1 {
                if (curr as usize) < self.cache_size && self.cache[curr as usize] != 0 {
                    steps += self.cache[curr as usize] as u32;
                    break;
                }

                if (curr as usize) < self.cache_size {
                    stack.push((curr as usize, steps));
                }

                if curr % 2 == 0 {
                    curr /= 2;
                    steps += 1;
                } else {
                    // 3 * curr + 1
                    let next = 3 * curr + 1;
                    if next > local_peak {
                        local_peak = next;
                    }
                    curr = next / 2;
                    steps += 2;
                }
            }

            // Fill cache for visited values
            for &(val, step_offset) in &stack {
                let rem = steps - step_offset;
                if rem <= u16::MAX as u32 {
                    self.cache[val] = rem as u16;
                }
            }

            if (n as usize) < self.cache_size && self.cache[n as usize] == 0 {
                if steps <= u16::MAX as u32 {
                    self.cache[n as usize] = steps as u16;
                }
            }

            // Check stopping time record
            if steps > max_stopping_time {
                max_stopping_time = steps;
                max_stopping_champ = n;
                stopping_records.push(RecordStoppingTime {
                    start_n: n,
                    stopping_time: steps,
                    peak_height: local_peak,
                });
            }

            // Check peak height record
            if local_peak > max_peak {
                max_peak = local_peak;
                max_peak_champ = n;
                peak_records.push(RecordPeakHeight {
                    start_n: n,
                    peak_height: local_peak,
                    stopping_time: steps,
                });
            }
        }

        let elapsed = start_time.elapsed().as_millis();

        CollatzRunStats {
            limit_n: self.limit,
            total_numbers_checked: self.limit,
            max_stopping_time_found: max_stopping_time,
            max_stopping_time_champion: max_stopping_champ,
            max_peak_height_found: max_peak,
            max_peak_height_champion: max_peak_champ,
            count_stopping_time_records: stopping_records.len(),
            count_peak_height_records: peak_records.len(),
            counterexamples_found: 0,
            stopping_time_records: stopping_records,
            peak_height_records: peak_records,
            execution_time_ms: elapsed,
        }
    }
}
