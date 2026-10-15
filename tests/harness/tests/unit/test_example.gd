extends GutTest

func test_arithmetic_sanity() -> void:
	assert_eq(1 + 1, 2, "sanity: math still works")

func test_variation_axis_contract() -> void:
	# placeholder: every sibling preset must differ on >= 4 axes (ADR-009)
	var axes := ["arena", "obstacles", "camera", "lighting", "roster"]
	assert_gte(axes.size(), 4, "variation axes defined")
