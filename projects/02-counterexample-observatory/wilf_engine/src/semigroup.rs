use serde::{Serialize, Deserialize};
use std::collections::BTreeSet;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct NumericalSemigroupRecord {
    pub genus: usize,
    pub frobenius: isize,
    pub conductor: usize,
    pub multiplicity: usize,
    pub embedding_dimension: usize,
    pub minimal_generators: Vec<usize>,
    pub num_elements_below_f: usize,
    pub wilf_defect: isize,
    pub wilf_ratio: f64,
    pub is_symmetric: bool,
}

pub struct NumericalSemigroup {
    pub gaps: BTreeSet<usize>,
    pub max_gap: Option<usize>,
}

impl NumericalSemigroup {
    pub fn new(gaps: BTreeSet<usize>) -> Self {
        let max_gap = gaps.iter().cloned().max();
        Self { gaps, max_gap }
    }

    pub fn contains(&self, x: usize) -> bool {
        !self.gaps.contains(&x)
    }

    pub fn genus(&self) -> usize {
        self.gaps.len()
    }

    pub fn frobenius(&self) -> isize {
        match self.max_gap {
            Some(f) => f as isize,
            None => -1,
        }
    }

    pub fn conductor(&self) -> usize {
        match self.max_gap {
            Some(f) => f + 1,
            None => 0,
        }
    }

    pub fn multiplicity(&self) -> usize {
        let mut x = 1;
        while self.gaps.contains(&x) {
            x += 1;
        }
        x
    }

    pub fn minimal_generators(&self) -> Vec<usize> {
        let cond = self.conductor();
        let mult = self.multiplicity();
        let limit = cond + mult;

        // Elements in S up to limit
        let mut s_elements = Vec::new();
        for x in 1..=limit {
            if self.contains(x) {
                s_elements.push(x);
            }
        }

        // A non-zero element x in S is a minimal generator iff x cannot be written as a + b for non-zero a, b in S
        let mut min_gens = Vec::new();
        for &x in &s_elements {
            let mut is_sum = false;
            for &a in &s_elements {
                if a >= x {
                    break;
                }
                let b = x - a;
                if self.contains(b) {
                    is_sum = true;
                    break;
                }
            }
            if !is_sum {
                min_gens.push(x);
            }
        }

        min_gens
    }

    pub fn embedding_dimension(&self) -> usize {
        self.minimal_generators().len()
    }

    pub fn num_elements_below_f(&self) -> usize {
        let f = self.frobenius();
        if f < 0 {
            return 1;
        }
        let mut count = 0;
        for x in 0..=(f as usize) {
            if self.contains(x) {
                count += 1;
            }
        }
        count
    }

    pub fn wilf_defect(&self) -> isize {
        let e = self.embedding_dimension() as isize;
        let n = self.num_elements_below_f() as isize;
        let f = self.frobenius();
        e * n - (f + 1)
    }

    pub fn wilf_ratio(&self) -> f64 {
        let e = self.embedding_dimension() as f64;
        let n = self.num_elements_below_f() as f64;
        let c = (self.frobenius() + 1) as f64;
        if e * n == 0.0 {
            1.0
        } else {
            c / (e * n)
        }
    }

    pub fn is_symmetric(&self) -> bool {
        let f = self.frobenius();
        if f < 0 {
            return true;
        }
        let f_val = f as usize;
        for &x in &self.gaps {
            if x <= f_val && self.gaps.contains(&(f_val - x)) {
                // Good, symmetric gap pairing
            } else if x <= f_val {
                return false;
            }
        }
        true
    }

    pub fn to_record(&self) -> NumericalSemigroupRecord {
        let min_gens = self.minimal_generators();
        let e = min_gens.len();
        let n = self.num_elements_below_f();
        let f = self.frobenius();
        let defect = (e as isize) * (n as isize) - (f + 1);
        let ratio = if e * n == 0 { 1.0 } else { (f + 1) as f64 / ((e * n) as f64) };

        NumericalSemigroupRecord {
            genus: self.genus(),
            frobenius: f,
            conductor: self.conductor(),
            multiplicity: self.multiplicity(),
            embedding_dimension: e,
            minimal_generators: min_gens,
            num_elements_below_f: n,
            wilf_defect: defect,
            wilf_ratio: ratio,
            is_symmetric: self.is_symmetric(),
        }
    }
}
