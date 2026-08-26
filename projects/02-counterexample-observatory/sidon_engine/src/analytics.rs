use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FrontierRecord {
    pub n: u32,
    pub r_n: usize,
    pub density: f64,
    pub asymptotic_ratio: f64,
    pub erdos_turan_deviation: f64,
    pub total_extremal_count: usize,
    pub canonical_count: usize,
    pub canonical_sets: Vec<Vec<u32>>,
    pub sample_extremal_set: Vec<u32>,
    pub all_extremal_sets: Vec<Vec<u32>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct GlobalReport {
    pub timestamp: String,
    pub max_n: u32,
    pub total_extremal_configurations: usize,
    pub oeis_match_verified: bool,
    pub records: Vec<FrontierRecord>,
}
