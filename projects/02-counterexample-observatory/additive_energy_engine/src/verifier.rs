use crate::energy::{
    compute_additive_energy, compute_sumset_size, count_additive_quadruples,
    make_arithmetic_progression, make_dissociated_set, theoretical_max_energy,
    theoretical_min_energy,
};

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Additive Energy Engine Self-Tests ===");

    for k in 2..=6 {
        // Test 1: Arithmetic Progression
        let ap = make_arithmetic_progression(k);
        let e_ap = compute_additive_energy(&ap);
        let q_ap = count_additive_quadruples(&ap);
        assert_eq!(e_ap, q_ap, "Quadruple count must match sum-frequency energy");
        let expected_max = theoretical_max_energy(k);
        assert_eq!(e_ap, expected_max, "AP must achieve theoretical maximum energy (2k^3+k)/3");

        // Test 2: Dissociated Set (Powers of 2)
        let dis = make_dissociated_set(k);
        let e_dis = compute_additive_energy(&dis);
        let q_dis = count_additive_quadruples(&dis);
        assert_eq!(e_dis, q_dis);
        let expected_min = theoretical_min_energy(k);
        assert_eq!(e_dis, expected_min, "Dissociated set must achieve theoretical minimum energy 2k^2-k");

        // Test 3: Cauchy-Schwarz inequality E(A) >= k^4 / |A+A|
        let sumset_ap = compute_sumset_size(&ap);
        let cs_ap = (k.pow(4) as f64) / (sumset_ap as f64);
        assert!(
            (e_ap as f64) >= cs_ap,
            "AP energy must satisfy Cauchy-Schwarz lower bound"
        );

        let sumset_dis = compute_sumset_size(&dis);
        let cs_dis = (k.pow(4) as f64) / (sumset_dis as f64);
        assert!(
            (e_dis as f64) >= cs_dis,
            "Dissociated energy must satisfy Cauchy-Schwarz lower bound"
        );

        println!("  k={} self-tests (AP={}, Dissociated={}, CS OK) -> Passed", k, e_ap, e_dis);
    }

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
