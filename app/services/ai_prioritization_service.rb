class AiPrioritizationService
  # A comprehensive but rule-based mapping
  SYMPTOM_DICTS = {
    high: [
      "chest pain", "difficulty breathing", "unconscious", "severe bleeding",
      "stroke", "seizure", "choking", "heart attack", "loss of vision",
      "suicidal", "severe head injury", "coughing up blood", "gunshot",
      "stab wound", "burning", "unresponsive", "paralysis"
    ],
    medium: [
      "fever", "vomiting", "dizziness", "severe pain", "broken bone",
      "abdominal pain", "migraine", "asthma", "dehydration",
      "fainting", "confusion", "allergic reaction", "diarrhea",
      "deep cut", "fracture", "high blood pressure"
    ],
    low: [
      "headache", "cough", "runny nose", "sore throat", "mild rash",
      "minor cut", "nausea", "fatigue", "muscle ache", "mild allergy",
      "earache", "cold", "flu", "sprain", "bruise", "toothache"
    ]
  }.freeze

  PRIORITY_LEVELS = { high: "HIGH", medium: "MEDIUM", low: "LOW" }.freeze

  def initialize(symptoms)
    @symptoms = Array(symptoms).reject(&:blank?).map { |s| s.to_s.downcase.strip }
  end

  def call
    return { priority_level: "LOW", priority_score: 10 } if @symptoms.empty?

    highest_tier = :low
    base_score = 10
    additional_symptoms_count = 0

    has_high = false
    has_medium = false

    @symptoms.each do |symptom|
      if matches_category?(symptom, :high)
        has_high = true
        additional_symptoms_count += 1
      elsif matches_category?(symptom, :medium)
        has_medium = true
        additional_symptoms_count += 1
      elsif matches_category?(symptom, :low) || symptom.present?
        # Even unknown symptoms count towards the overall issue weight
        additional_symptoms_count += 1
      end
    end

    if has_high
      highest_tier = :high
      base_score = 80
    elsif has_medium
      highest_tier = :medium
      base_score = 50
    else
      highest_tier = :low
      base_score = 20
    end

    # Calculate final score: Base score + 5 per additional symptom
    score_bump = [additional_symptoms_count - 1, 0].max * 5
    final_score = base_score + score_bump

    # Cap scores within their tiers
    # HIGH: 80-100, MEDIUM: 50-79, LOW: 10-49
    final_score = limit_score(final_score, highest_tier)

    {
      priority_level: PRIORITY_LEVELS[highest_tier],
      priority_score: final_score
    }
  end

  private

  def matches_category?(symptom, category)
    # Doing partial matching allows detection of strings like "severe chest pain" matching "chest pain"
    SYMPTOM_DICTS[category].any? { |keyword| symptom.include?(keyword) }
  end

  def limit_score(score, tier)
    case tier
    when :high
      [score, 100].min
    when :medium
      [score, 79].min
    when :low
      [score, 49].min
    end
  end
end
