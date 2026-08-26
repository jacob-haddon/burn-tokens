use crate::balance::analyze_poset_balance;
use crate::generator::generate_all_posets_up_to;
use crate::linear_extensions::{compute_extension_stats_backtrack, compute_extension_stats_dp};
use crate::poset::Poset;

pub const OEIS_A000112: [usize; 9] = [
    0,      // n = 0
    1,      // n = 1
    2,      // n = 2
    5,      // n = 3
    16,     // n = 4
    63,     // n = 5
    318,    // n = 6
    2045,   // n = 7
    16999,  // n = 8
];

/// Run comprehensive self-tests on the poset engine.
pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Poset Engine Verification Tests ===");

    // Test 1: Generate posets up to n = 6 and check OEIS counts
    let max_n = 6;
    println!("Test 1: Verifying non-isomorphic poset counts up to n = {} against OEIS A000112...", max_n);
    let levels = generate_all_posets_up_to(max_n);

    for n in 1..=max_n {
        let count = levels[n].len();
        let expected = OEIS_A000112[n];
        println!("  n = {}: generated {} posets (expected {})", n, count, expected);
        if count != expected {
            return Err(format!("OEIS count mismatch at n = {}: got {}, expected {}", n, count, expected));
        }
    }

    // Test 2: Verify DP linear extension counts against DFS backtrack on all posets up to n = 5
    println!("Test 2: Cross-validating DP vs Backtracking Topological Sort on all posets up to n = 5...");
    for n in 1..=5 {
        for (i, p) in levels[n].iter().enumerate() {
            let stats_dp = compute_extension_stats_dp(p);
            let stats_bt = compute_extension_stats_backtrack(p);

            if stats_dp.total_extensions != stats_bt.total_extensions {
                return Err(format!(
                    "Linear extension count mismatch at n = {}, poset #{}: DP={}, BT={}",
                    n, i, stats_dp.total_extensions, stats_bt.total_extensions
                ));
            }

            if stats_dp.pair_stats.len() != stats_bt.pair_stats.len() {
                return Err(format!("Pair stats length mismatch at n = {}, poset #{}", n, i));
            }

            for (p_dp, p_bt) in stats_dp.pair_stats.iter().zip(stats_bt.pair_stats.iter()) {
                if p_dp.e_u_less_v != p_bt.e_u_less_v || p_dp.e_v_less_u != p_bt.e_v_less_u {
                    return Err(format!(
                        "Pair count mismatch at n = {}, poset #{}, pair ({}, {}): DP=({}, {}), BT=({}, {})",
                        n, i, p_dp.u, p_dp.v, p_dp.e_u_less_v, p_dp.e_v_less_u, p_bt.e_u_less_v, p_bt.e_v_less_u
                    ));
                }
            }
        }
    }
    println!("  All DP vs Backtrack checks passed perfectly.");

    // Test 3: Test known hand-calculated posets
    println!("Test 3: Hand-calculated benchmark posets...");
    // Hand case 1: Antichain of size 3 (0, 1, 2 with no relations)
    let p_anti3 = Poset::new(3);
    let st_anti3 = compute_extension_stats_dp(&p_anti3);
    assert_eq!(st_anti3.total_extensions, 6, "3-antichain must have 3! = 6 extensions");
    let bal_anti3 = analyze_poset_balance(st_anti3);
    assert_eq!((bal_anti3.delta_num, bal_anti3.delta_den), (1, 2), "3-antichain balance must be 1/2");

    // Hand case 2: Chain of size 3 (0 < 1 < 2)
    let p_chain3 = Poset::from_relations(3, &[(0, 1), (1, 2)]).unwrap();
    let st_chain3 = compute_extension_stats_dp(&p_chain3);
    assert_eq!(st_chain3.total_extensions, 1, "3-chain must have 1 extension");
    let bal_chain3 = analyze_poset_balance(st_chain3);
    assert!(bal_chain3.is_total_order, "3-chain must be a total order");

    // Hand case 3: Classic 1/3-extremal poset on 3 elements: 0 < 1, 2 isolated
    let p_ext3 = Poset::from_relations(3, &[(0, 1)]).unwrap();
    let st_ext3 = compute_extension_stats_dp(&p_ext3);
    assert_eq!(st_ext3.total_extensions, 3, "2+1 poset must have 3 extensions");
    let bal_ext3 = analyze_poset_balance(st_ext3);
    assert_eq!((bal_ext3.delta_num, bal_ext3.delta_den), (1, 3), "2+1 poset balance must be exactly 1/3");
    assert!(bal_ext3.is_strictly_one_third, "2+1 poset must be marked strictly 1/3");

    println!("  Hand-calculated benchmark posets passed.");
    println!("=== All Self-Tests Passed Successfully ===");
    Ok(())
}
