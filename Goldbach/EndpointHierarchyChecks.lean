import Goldbach.EndpointHierarchy

/-!
# Checks for the endpoint hierarchy

Every declaration added by `Goldbach.EndpointHierarchy` is printed here, together
with its axiom set.  The literal arrows are restated so that a change in the
meaning of the shape predicates cannot silently change the hierarchy.
-/

namespace Goldbach

#check @wu_exponent_implies_liu_exponent
#check @onePlusOne8938Shape_implies_onePlusOneNineShape
#check @onePlusOneNineShape_implies_chen
#check @onePlusOne8938Shape_implies_chen
#check @binaryGoldbach_implies_endpoint_chain

example : OnePlusOne8938Shape → OnePlusOneNineShape :=
  onePlusOne8938Shape_implies_onePlusOneNineShape

example : OnePlusOneNineShape → ChenTheorem :=
  onePlusOneNineShape_implies_chen

example : OnePlusOne8938Shape → ChenTheorem :=
  onePlusOne8938Shape_implies_chen

#print axioms wu_exponent_implies_liu_exponent
#print axioms onePlusOne8938Shape_implies_onePlusOneNineShape
#print axioms onePlusOneNineShape_implies_chen
#print axioms onePlusOne8938Shape_implies_chen
#print axioms binaryGoldbach_implies_endpoint_chain

end Goldbach
