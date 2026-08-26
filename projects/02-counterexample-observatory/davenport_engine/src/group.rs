use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct FiniteGroup {
    pub name: String,
    pub order: usize,
    pub is_abelian: bool,
    pub cayley_table: Vec<Vec<usize>>,
    pub inverses: Vec<usize>,
    pub element_orders: Vec<usize>,
}

impl FiniteGroup {
    pub fn new(name: String, order: usize, cayley_table: Vec<Vec<usize>>) -> Self {
        assert_eq!(cayley_table.len(), order);
        for row in &cayley_table {
            assert_eq!(row.len(), order);
        }

        // Check is_abelian
        let mut abelian = true;
        for i in 0..order {
            for j in 0..order {
                if cayley_table[i][j] != cayley_table[j][i] {
                    abelian = false;
                    break;
                }
            }
            if !abelian {
                break;
            }
        }

        // Compute inverses
        let mut inverses = vec![0; order];
        for i in 0..order {
            let mut found = false;
            for j in 0..order {
                if cayley_table[i][j] == 0 && cayley_table[j][i] == 0 {
                    inverses[i] = j;
                    found = true;
                    break;
                }
            }
            assert!(found, "Element {} has no inverse in group {}", i, name);
        }

        // Compute element orders
        let mut element_orders = vec![1; order];
        for x in 1..order {
            let mut curr = x;
            let mut ord = 1;
            while curr != 0 {
                curr = cayley_table[curr][x];
                ord += 1;
                assert!(ord <= order, "Order overflow");
            }
            element_orders[x] = ord;
        }

        let grp = Self {
            name,
            order,
            is_abelian: abelian,
            cayley_table,
            inverses,
            element_orders,
        };
        grp.verify_axioms();
        grp
    }

    pub fn verify_axioms(&self) {
        let n = self.order;
        // 1. Identity 0
        for i in 0..n {
            assert_eq!(self.cayley_table[0][i], i, "Left identity fail at {}", i);
            assert_eq!(self.cayley_table[i][0], i, "Right identity fail at {}", i);
        }

        // 2. Associativity
        for a in 0..n {
            for b in 0..n {
                let ab = self.cayley_table[a][b];
                for c in 0..n {
                    let bc = self.cayley_table[b][c];
                    assert_eq!(
                        self.cayley_table[ab][c],
                        self.cayley_table[a][bc],
                        "Associativity fail in {} at ({}, {}, {})",
                        self.name, a, b, c
                    );
                }
            }
        }
    }

    /// Cyclic group Z_n
    pub fn cyclic(n: usize) -> Self {
        let mut table = vec![vec![0; n]; n];
        for i in 0..n {
            for j in 0..n {
                table[i][j] = (i + j) % n;
            }
        }
        Self::new(format!("Z_{}", n), n, table)
    }

    /// Direct product G x H
    pub fn direct_product(&self, other: &Self) -> Self {
        let n1 = self.order;
        let n2 = other.order;
        let order = n1 * n2;
        let mut table = vec![vec![0; order]; order];

        for i1 in 0..n1 {
            for j1 in 0..n2 {
                let idx1 = i1 * n2 + j1;
                for i2 in 0..n1 {
                    for j2 in 0..n2 {
                        let idx2 = i2 * n2 + j2;
                        let res_i = self.cayley_table[i1][i2];
                        let res_j = other.cayley_table[j1][j2];
                        table[idx1][idx2] = res_i * n2 + res_j;
                    }
                }
            }
        }

        Self::new(format!("{}x{}", self.name, other.name), order, table)
    }

    /// Dihedral group D_{2n}
    pub fn dihedral(n: usize) -> Self {
        let order = 2 * n;
        let mut table = vec![vec![0; order]; order];

        for i1 in 0..n {
            for j1 in 0..2 {
                let idx1 = i1 + j1 * n;
                for i2 in 0..n {
                    for j2 in 0..2 {
                        let idx2 = i2 + j2 * n;
                        let (res_i, res_j) = if j1 == 0 {
                            ((i1 + i2) % n, j2)
                        } else {
                            let diff = (i1 as isize - i2 as isize).rem_euclid(n as isize) as usize;
                            (diff, (1 + j2) % 2)
                        };
                        table[idx1][idx2] = res_i + res_j * n;
                    }
                }
            }
        }

        Self::new(format!("D_{}", 2 * n), order, table)
    }

    /// Dicyclic / Generalized Quaternion group Dic_n (order 4n)
    pub fn dicyclic(n: usize) -> Self {
        let order = 4 * n;
        let n2 = 2 * n;
        let mut table = vec![vec![0; order]; order];

        for i1 in 0..n2 {
            for j1 in 0..2 {
                let idx1 = i1 + j1 * n2;
                for i2 in 0..n2 {
                    for j2 in 0..2 {
                        let idx2 = i2 + j2 * n2;
                        let (res_i, res_j) = if j1 == 0 {
                            ((i1 + i2) % n2, j2)
                        } else {
                            let base_i = (i1 as isize - i2 as isize).rem_euclid(n2 as isize) as usize;
                            if j2 == 0 {
                                (base_i, 1)
                            } else {
                                ((base_i + n) % n2, 0)
                            }
                        };
                        table[idx1][idx2] = res_i + res_j * n2;
                    }
                }
            }
        }

        let name = if n == 2 {
            "Q_8".to_string()
        } else if n == 4 {
            "Q_16".to_string()
        } else if n == 8 {
            "Q_32".to_string()
        } else {
            format!("Dic_{}", n)
        };

        Self::new(name, order, table)
    }

    /// Alternating group A_4
    pub fn alternating_4() -> Self {
        let perms: Vec<[usize; 4]> = vec![
            [0, 1, 2, 3], [0, 2, 3, 1], [0, 3, 1, 2],
            [1, 2, 0, 3], [2, 0, 1, 3], [1, 0, 3, 2],
            [2, 3, 0, 1], [3, 2, 1, 0], [1, 3, 2, 0],
            [3, 0, 2, 1], [2, 1, 3, 0], [3, 1, 0, 2],
        ];

        let mut table = vec![vec![0; 12]; 12];
        for i in 0..12 {
            for j in 0..12 {
                let mut comp = [0; 4];
                for k in 0..4 {
                    comp[k] = perms[i][perms[j][k]];
                }
                let mut match_idx = None;
                for (k, p) in perms.iter().enumerate() {
                    if *p == comp {
                        match_idx = Some(k);
                        break;
                    }
                }
                table[i][j] = match_idx.expect("A4 composition not found");
            }
        }

        Self::new("A_4".to_string(), 12, table)
    }

    /// Semidihedral group SD_16: <r, s | r^8=1, s^2=1, srs=r^3>
    pub fn semidihedral_16() -> Self {
        let n = 8;
        let order = 16;
        let mut table = vec![vec![0; 16]; 16];

        for i1 in 0..n {
            for j1 in 0..2 {
                let idx1 = i1 + j1 * n;
                for i2 in 0..n {
                    for j2 in 0..2 {
                        let idx2 = i2 + j2 * n;
                        let (res_i, res_j) = if j1 == 0 {
                            ((i1 + i2) % n, j2)
                        } else {
                            ((i1 + 3 * i2) % n, (1 + j2) % 2)
                        };
                        table[idx1][idx2] = res_i + res_j * n;
                    }
                }
            }
        }

        Self::new("SD_16".to_string(), order, table)
    }

    /// Frobenius group F_20 = Z_5 \rtimes Z_4
    pub fn frobenius_20() -> Self {
        let n_a = 5;
        let n_b = 4;
        let order = 20;
        let mut table = vec![vec![0; 20]; 20];
        let pow2 = [1, 2, 4, 3];

        for i1 in 0..n_a {
            for j1 in 0..n_b {
                let idx1 = i1 + j1 * n_a;
                for i2 in 0..n_a {
                    for j2 in 0..n_b {
                        let idx2 = i2 + j2 * n_a;
                        let res_i = (i1 + i2 * pow2[j1]) % n_a;
                        let res_j = (j1 + j2) % n_b;
                        table[idx1][idx2] = res_i + res_j * n_a;
                    }
                }
            }
        }

        Self::new("F_20".to_string(), order, table)
    }

    /// Frobenius group F_21 = Z_7 \rtimes Z_3
    pub fn frobenius_21() -> Self {
        let n_a = 7;
        let n_b = 3;
        let order = 21;
        let mut table = vec![vec![0; 21]; 21];
        let pow2 = [1, 2, 4]; // 2^j mod 7

        for i1 in 0..n_a {
            for j1 in 0..n_b {
                let idx1 = i1 + j1 * n_a;
                for i2 in 0..n_a {
                    for j2 in 0..n_b {
                        let idx2 = i2 + j2 * n_a;
                        let res_i = (i1 + i2 * pow2[j1]) % n_a;
                        let res_j = (j1 + j2) % n_b;
                        table[idx1][idx2] = res_i + res_j * n_a;
                    }
                }
            }
        }

        Self::new("F_21".to_string(), order, table)
    }
}
