use crate::metrics::SetMetrics;
use crate::search::find_exact_extremal_sum_product;

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Sum-Product Engine Self-Tests ===");

    // Test 1: Arithmetic Progression AP_5 = {1, 2, 3, 4, 5}
    let ap = vec![1, 2, 3, 4, 5];
    let ap_metrics = SetMetrics::compute(&ap);
    assert_eq!(ap_metrics.sumset_size, 9, "AP_5 sumset must be 2*5 - 1 = 9");
    assert_eq!(ap_metrics.productset_size, 14, "AP_5 productset must be 14");
    println!("  AP_5: |A+A| = {}, |A*A| = {} -> OK", ap_metrics.sumset_size, ap_metrics.productset_size);

    // Test 2: Geometric Progression GP_5 = {1, 2, 4, 8, 16}
    let gp = vec![1, 2, 4, 8, 16];
    let gp_metrics = SetMetrics::compute(&gp);
    assert_eq!(gp_metrics.productset_size, 9, "GP_5 productset must be 2*5 - 1 = 9");
    assert_eq!(gp_metrics.sumset_size, 15, "GP_5 sumset must be 15");
    println!("  GP_5: |A+A| = {}, |A*A| = {} -> OK", gp_metrics.sumset_size, gp_metrics.productset_size);

    // Test 3: Cauchy-Schwarz Energy Bounds
    let k = 5.0f64;
    let cs_bound_plus = (k.powi(4) / ap_metrics.sumset_size as f64).ceil() as u64;
    assert!(ap_metrics.additive_energy >= cs_bound_plus, "Additive energy below CS bound");
    let cs_bound_times = (k.powi(4) / gp_metrics.productset_size as f64).ceil() as u64;
    assert!(gp_metrics.multiplicative_energy >= cs_bound_times, "Multiplicative energy below CS bound");
    println!("  Cauchy-Schwarz energy bounds verified.");

    // Test 4: Known small minimums
    let (min_2, _) = find_exact_extremal_sum_product(2, 10);
    assert_eq!(min_2, 3, "k=2 min max must be 3");
    let (min_3, _) = find_exact_extremal_sum_product(3, 10);
    assert_eq!(min_3, 6, "k=3 min max must be 6");
    let (min_4, _) = find_exact_extremal_sum_product(4, 12);
    assert_eq!(min_4, 9, "k=4 min max must be 9");
    println!("  Known finite minimums for k=2,3,4 verified.");

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
