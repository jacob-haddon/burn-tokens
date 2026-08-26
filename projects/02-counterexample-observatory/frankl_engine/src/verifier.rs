use crate::family::SetFamily;
use crate::generator::generate_all_exhaustive;

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Frankl Engine Verification Tests ===");

    // Test 1: Hand-crafted known families
    println!("Test 1: Hand-crafted test cases...");
    
    // Case 1.1: Full power set on m = 3 with empty set (8 sets)
    let p3 = SetFamily::new(3, (0..8).collect());
    assert!(p3.is_union_closed(), "Power set must be union-closed");
    let stats_p3 = p3.analyze();
    assert_eq!(stats_p3.size, 8);
    assert_eq!(stats_p3.max_frequency, 4);
    assert_eq!((stats_p3.max_freq_num, stats_p3.max_freq_den), (1, 2));
    assert!(stats_p3.is_strictly_half, "Power set on 3 must be strictly 1/2");
    assert!(stats_p3.satisfies_frankl, "Power set must satisfy Frankl");

    // Case 1.2: Family {empty, {0,1}, {0,2}, {0,1,2}} on m = 3
    let f1 = SetFamily::new(3, vec![0, 0b011, 0b101, 0b111]);
    assert!(f1.is_union_closed());
    let stats_f1 = f1.analyze();
    assert_eq!(stats_f1.size, 4);
    assert_eq!(stats_f1.max_frequency, 3); // element 0 is in 3 sets
    assert_eq!((stats_f1.max_freq_num, stats_f1.max_freq_den), (3, 4));
    assert!(stats_f1.satisfies_frankl);

    // Case 1.3: Non-closed family test
    let f_not_closed = SetFamily::new(3, vec![0b001, 0b010]); // {0}, {1} without {0,1}
    assert!(!f_not_closed.is_union_closed(), "Family lacking union must fail closure check");

    println!("  Hand-crafted cases passed.");

    // Test 2: Exhaustive validation for m = 1, 2, 3
    println!("Test 2: Exhaustive validation for m = 1, 2, 3...");
    for m in 1..=3 {
        let families = generate_all_exhaustive(m);
        println!("  m = {}: found {} union-closed families", m, families.len());
        for f in &families {
            assert!(f.is_union_closed());
            let stats = f.analyze();
            if stats.active_elements > 0 {
                assert!(
                    stats.satisfies_frankl,
                    "Frankl violation in exhaustive m={} test!",
                    m
                );
            }
        }
    }

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
