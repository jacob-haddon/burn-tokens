use crate::generator::generate_all_unrooted_trees;
use crate::solver::{find_graceful_labeling, is_graceful};
use crate::tree::Tree;

pub const OEIS_A000055: [usize; 9] = [
    0,   // n = 0
    1,   // n = 1
    1,   // n = 2
    1,   // n = 3
    2,   // n = 4
    3,   // n = 5
    6,   // n = 6
    11,  // n = 7
    23,  // n = 8
];

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Graceful Tree Engine Verification Tests ===");

    // Test 1: Validate OEIS A000055 tree generation counts up to n = 8
    println!("Test 1: Verifying tree counts against OEIS A000055 up to n = 8...");
    for n in 1..=8 {
        let trees = generate_all_unrooted_trees(n);
        let expected = OEIS_A000055[n];
        println!("  n = {}: generated {} trees (expected {})", n, trees.len(), expected);
        if trees.len() != expected {
            return Err(format!("Tree count mismatch at n = {}: got {}, expected {}", n, trees.len(), expected));
        }
    }

    // Test 2: Hand-crafted benchmark families (Path graphs P_n, Star graphs S_n)
    println!("Test 2: Hand-crafted benchmark tree families...");
    for n in 3..=8 {
        // Path P_n: 0-1-2-...-(n-1)
        let p_edges: Vec<(usize, usize)> = (0..(n - 1)).map(|i| (i, i + 1)).collect();
        let path_tree = Tree::new(n, p_edges);
        let path_label = find_graceful_labeling(&path_tree).expect("Path graph must be graceful");
        assert!(is_graceful(&path_tree, &path_label), "Path P_{} labeling invalid", n);

        // Star S_n: 0 connected to 1..n-1
        let s_edges: Vec<(usize, usize)> = (1..n).map(|i| (0, i)).collect();
        let star_tree = Tree::new(n, s_edges);
        let star_label = find_graceful_labeling(&star_tree).expect("Star graph must be graceful");
        assert!(is_graceful(&star_tree, &star_label), "Star S_{} labeling invalid", n);
    }
    println!("  Paths and Stars validated successfully.");

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
