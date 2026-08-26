use crate::waring::WaringSolver;

pub fn run_self_tests() -> Result<(), String> {
    println!("=== Running Waring Engine Self-Tests ===");

    // Test 1: k = 2 (Squares, g(2) = 4)
    let solver_2 = WaringSolver::new(2, 1000);
    assert_eq!(solver_2.min_terms(7), 4, "7 must require 4 squares (4=2^2+1^2+1^2+1^2)");
    let w_7 = solver_2.reconstruct_witness(7);
    assert_eq!(w_7.len(), 4);
    assert_eq!(w_7.iter().map(|&x| x * x).sum::<usize>(), 7);
    println!("  k=2 self-test: 7 = {:?}^2 -> OK", w_7);

    // Test 2: k = 3 (Cubes, g(3) = 9)
    let solver_3 = WaringSolver::new(3, 1000);
    assert_eq!(solver_3.min_terms(23), 9, "23 must require 9 cubes");
    assert_eq!(solver_3.min_terms(239), 9, "239 must require 9 cubes");
    let w_23 = solver_3.reconstruct_witness(23);
    assert_eq!(w_23.len(), 9);
    assert_eq!(w_23.iter().map(|&x| x * x * x).sum::<usize>(), 23);
    let w_239 = solver_3.reconstruct_witness(239);
    assert_eq!(w_239.len(), 9);
    assert_eq!(w_239.iter().map(|&x| x * x * x).sum::<usize>(), 239);
    println!("  k=3 self-test: 23 = {:?}^3 and 239 = {:?}^3 -> OK", w_23, w_239);

    // Test 3: k = 4 (Fourth powers, g(4) = 19)
    let solver_4 = WaringSolver::new(4, 1000);
    assert_eq!(solver_4.min_terms(79), 19, "79 must require 19 fourth powers");
    let w_79 = solver_4.reconstruct_witness(79);
    assert_eq!(w_79.len(), 19);
    assert_eq!(w_79.iter().map(|&x| x.pow(4)).sum::<usize>(), 79);
    println!("  k=4 self-test: 79 = {:?}^4 -> OK", w_79);

    // Test 4: k = 5 (Fifth powers, g(5) = 37)
    let solver_5 = WaringSolver::new(5, 1000);
    assert_eq!(solver_5.min_terms(223), 37, "223 must require 37 fifth powers");
    let w_223 = solver_5.reconstruct_witness(223);
    assert_eq!(w_223.len(), 37);
    assert_eq!(w_223.iter().map(|&x| x.pow(5)).sum::<usize>(), 223);
    println!("  k=5 self-test: 223 = {:?}^5 -> OK", w_223);

    println!("=== All Self-Tests Passed Successfully ===\n");
    Ok(())
}
