import CompleteLattice.Basic

namespace CompleteLattice

variable {α : Type u} [CompleteLattice α]

def lfp (h : α → α) : α :=
  CompleteLattice.sInf (fun x => h x ≤ x)

def gfp (h : α → α) : α :=
  CompleteLattice.sSup (fun x => x ≤ h x)

theorem lfp_le_of_prefixed {h : α → α} {x : α} (hx : h x ≤ x) : lfp h ≤ x :=
  CompleteLattice.sInf_le (fun y => h y ≤ y) x hx

theorem le_lfp_of_lower_bound {h : α → α} {p : α} (hp : ∀ x, h x ≤ x → p ≤ x) : p ≤ lfp h :=
  CompleteLattice.le_sInf (fun y => h y ≤ y) p hp

theorem lfp_prefixed {h : α → α} (mono : Monotone h) : h (lfp h) ≤ lfp h := by
  apply le_lfp_of_lower_bound
  intro x hx
  have h_le : lfp h ≤ x := lfp_le_of_prefixed hx
  have h_mono : h (lfp h) ≤ h x := mono h_le
  exact trans h_mono hx

theorem prefixed_of_lfp {h : α → α} (mono : Monotone h) : lfp h ≤ h (lfp h) := by
  have h1 : h (lfp h) ≤ lfp h := lfp_prefixed mono
  have h2 : h (h (lfp h)) ≤ h (lfp h) := mono h1
  exact lfp_le_of_prefixed h2

theorem lfp_fixed_point {h : α → α} (mono : Monotone h) : h (lfp h) = lfp h :=
  antisymm (lfp_prefixed mono) (prefixed_of_lfp mono)

theorem lfp_least {h : α → α} (_mono : Monotone h) (x : α) (hx : h x = x) : lfp h ≤ x := by
  have h_pre : h x ≤ x := by
    rw [hx]
    exact refl x
  exact lfp_le_of_prefixed h_pre

theorem gfp_ge_of_postfixed {h : α → α} {x : α} (hx : x ≤ h x) : x ≤ gfp h :=
  CompleteLattice.le_sSup (fun y => y ≤ h y) x hx

theorem gfp_le_of_upper_bound {h : α → α} {q : α} (hq : ∀ x, x ≤ h x → x ≤ q) : gfp h ≤ q :=
  CompleteLattice.sSup_le (fun y => y ≤ h y) q hq

theorem postfixed_gfp {h : α → α} (mono : Monotone h) : gfp h ≤ h (gfp h) := by
  apply gfp_le_of_upper_bound
  intro x hx
  have h_ge : x ≤ gfp h := gfp_ge_of_postfixed hx
  have h_mono : h x ≤ h (gfp h) := mono h_ge
  exact trans hx h_mono

theorem gfp_postfixed {h : α → α} (mono : Monotone h) : h (gfp h) ≤ gfp h := by
  have h1 : gfp h ≤ h (gfp h) := postfixed_gfp mono
  have h2 : h (gfp h) ≤ h (h (gfp h)) := mono h1
  exact gfp_ge_of_postfixed h2

theorem gfp_fixed_point {h : α → α} (mono : Monotone h) : h (gfp h) = gfp h :=
  antisymm (gfp_postfixed mono) (postfixed_gfp mono)

theorem gfp_greatest {h : α → α} (_mono : Monotone h) (x : α) (hx : h x = x) : x ≤ gfp h := by
  have h_post : x ≤ h x := by
    rw [hx]
    exact refl x
  exact gfp_ge_of_postfixed h_post

end CompleteLattice
