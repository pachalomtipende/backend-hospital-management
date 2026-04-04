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
    result = AiPrioritizationService.new(["chest paint"]).call # Should be unknown
    assert_equal "LOW", result[:priority_level]
  end

  test "extracts multiple symptoms from a full sentence" do
    sentence = "I have severe chest pain and a little bit of fever."
    result = AiPrioritizationService.new(sentence).call
    assert_equal "HIGH", result[:priority_level]
    # Should find 'chest pain' (high) and 'fever' (medium)
    assert_includes result[:detected_symptoms], "chest pain"
    assert_includes result[:detected_symptoms], "fever"
    # base 80 + 5 (1 extra symptom) = 85
    assert_equal 85, result[:priority_score]
  end

  test "applies severe severity bump within LOW tier" do
    # 'cough' is low (base 20). Severe bump (+10) => 30.
    result = AiPrioritizationService.new("I have a bad cough", severity: "severe").call
    assert_equal "LOW", result[:priority_level]
    assert_equal 30, result[:priority_score]
  end

  test "applies moderate severity bump to MEDIUM tier" do
    # 'fever' is medium (base 50). Moderate bump (+5) => 55.
    result = AiPrioritizationService.new(["fever"], severity: "moderate").call
    assert_equal "MEDIUM", result[:priority_level]
    assert_equal 55, result[:priority_score]
  end

  test "does not allow severity bump to cross LOW to MEDIUM boundary" do
    # Let's say we have many low symptoms.
    # Base 20 + 5 extra symptoms * 5 = 45.
    # Severe bump (+10) => 55.
    # BUT, since all are LOW, it must be capped at 49.
    symptoms = ["cough", "headache", "runny nose", "sore throat", "mild rash", "fatigue"]
    result = AiPrioritizationService.new(symptoms, severity: "severe").call
    assert_equal "LOW", result[:priority_level]
    assert_equal 49, result[:priority_score]
  end

  test "handles negation in full sentences" do
    sentence = "I have a cough but I do not have chest pain."
    result = AiPrioritizationService.new(sentence).call
    assert_equal "LOW", result[:priority_level]
    assert_includes result[:detected_symptoms], "cough"
    refute_includes result[:detected_symptoms], "chest pain"
  end
end
