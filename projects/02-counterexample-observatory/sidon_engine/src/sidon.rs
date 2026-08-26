use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub struct SidonSet {
    pub elements: Vec<u32>,
    pub n_universe: u32,
}

impl SidonSet {
    pub fn new(mut elements: Vec<u32>, n_universe: u32) -> Self {
        elements.sort_unstable();
        elements.dedup();
        Self { elements, n_universe }
    }

    pub fn size(&self) -> usize {
        self.elements.len()
    }

    pub fn span(&self) -> u32 {
        if self.elements.is_empty() {
            0
        } else {
            self.elements.last().unwrap() - self.elements.first().unwrap()
        }
    }

    /// Verifies Sidon property via pairwise sums uniqueness
    pub fn is_valid_sidon_sums(&self) -> bool {
        is_sidon_sum_form(&self.elements)
    }

    /// Verifies Sidon property via pairwise differences uniqueness
    pub fn is_valid_sidon_diffs(&self) -> bool {
        is_sidon_diff_form(&self.elements)
    }

    /// Canonical representative under translation and reflection
    pub fn canonical(&self) -> Vec<u32> {
        if self.elements.is_empty() {
            return vec![];
        }
        let first = self.elements[0];
        let last = *self.elements.last().unwrap();
        
        // Translated to start at 1
        let translated: Vec<u32> = self.elements.iter().map(|&x| x - first + 1).collect();
        
        // Reflected and translated to start at 1
        let mut reflected: Vec<u32> = self.elements.iter().map(|&x| last - x + 1).collect();
        reflected.sort_unstable();
        
        if translated <= reflected {
            translated
        } else {
            reflected
        }
    }
}

/// Check if a sorted slice of positive integers forms a Sidon set (B2 set)
/// via explicit pairwise sum calculation.
pub fn is_sidon_sum_form(elements: &[u32]) -> bool {
    let mut sums = HashSet::new();
    let k = elements.len();
    for i in 0..k {
        for j in i..k {
            let s = elements[i] + elements[j];
            if !sums.insert(s) {
                return false;
            }
        }
    }
    true
}

/// Check if a sorted slice of positive integers forms a Sidon set
/// via explicit pairwise difference calculation.
pub fn is_sidon_diff_form(elements: &[u32]) -> bool {
    let mut diffs = HashSet::new();
    let k = elements.len();
    for i in 0..k {
        for j in (i + 1)..k {
            let d = elements[j] - elements[i];
            if !diffs.insert(d) {
                return false;
            }
        }
    }
    true
}
