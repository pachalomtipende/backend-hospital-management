require "test_helper"

class AiPrioritizationServiceTest < ActiveSupport::TestCase
  test "returns HIGH priority for a single high symptom" do
    result = AiPrioritizationService.new(["chest pain"]).call
    assert_equal "HIGH", result[:priority_level]
  end

  test "base score is 80 for a single high symptom" do
    result = AiPrioritizationService.new(["chest pain"]).call
    assert_equal 80, result[:priority_score]
  end

  test "returns HIGH for high+medium symptoms and adds bump" do
    result = AiPrioritizationService.new(["chest pain", "fever", "cough"]).call
    assert_equal "HIGH", result[:priority_level]
    # base 80 + 2 additional symptoms (2 * 5 = 10) = 90
    assert_equal 90, result[:priority_score]
  end

  test "handles no symptoms gracefully" do
    result = AiPrioritizationService.new([]).call
    assert_equal "LOW", result[:priority_level]
    assert_equal 10, result[:priority_score]
  end

  test "caps score appropriately within tiers" do
    # Medium tier with 7 symptoms => base 50 + 6*5=30 => 80. Cap for medium is 79.
    symptoms = ["fever", "vomiting", "dizziness", "severe pain", "broken bone", "abdominal pain", "migraine"]
    result = AiPrioritizationService.new(symptoms).call
    assert_equal "MEDIUM", result[:priority_level]
    assert_equal 79, result[:priority_score]
  end

  test "case insensitive matching" do
    result = AiPrioritizationService.new(["ChEsT pAiN"]).call
    assert_equal "HIGH", result[:priority_level]
  end

  test "unknown symptoms default to LOW but bump score" do
    # Base low is 20 + 1 extra = 25
    result = AiPrioritizationService.new(["unknown symptom 1", "unknown symptom 2"]).call
    assert_equal "LOW", result[:priority_level]
    assert_equal 25, result[:priority_score]
  end

  test "ignores negated symptoms like 'no chest pain'" do
    result = AiPrioritizationService.new(["no chest pain", "not fever"]).call
    assert_equal "LOW", result[:priority_level]
    assert_equal 25, result[:priority_score] # 2 symptoms
  end

  test "matches exact words with word boundaries" do
    # 'headache' should not match 'ache' if 'ache' was in high priority
    # Here, 'chest pain' shouldn't be matched by 'chest pains' (unless plural matching is added)
    # But let's test if 'pain' matches 'severe pain' 
    result = AiPrioritizationService.new(["chest paint"]).call # Should be unknown
    assert_equal "LOW", result[:priority_level]
  end
end
