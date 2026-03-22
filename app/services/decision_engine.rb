# frozen_string_literal: true

module DecisionEngine
  module_function

  def questions
    {
      intro: {
        id: 'intro',
        title: 'Tell us about this request',
        help: 'Start with the applicant details used by the admin dashboard and final recommendation summary.',
        fields: [
          { id: 'applicantName', label: 'Applicant name', type: 'text', placeholder: 'Jordan Lee' },
          { id: 'applicantEmail', label: 'Applicant email', type: 'email', placeholder: 'jordan@example.com' }
        ],
        next: 'entityType'
      },
      entityType: {
        id: 'entityType',
        title: 'Who is seeking help?',
        help: 'Choose the applicant type so the screening flow can branch into the appropriate eligibility path.',
        fields: [
          {
            id: 'entityType', label: 'Applicant type', type: 'radio', options: [
              { value: 'small_business', label: 'Small business' },
              { value: 'nonprofit', label: 'Nonprofit organization' },
              { value: 'individual', label: 'Individual' }
            ]
          }
        ]
      },
      yearsActive: {
        id: 'yearsActive',
        title: 'How long has the business been operating?',
        help: 'Business tenure affects eligibility and whether the request should move straight to a program or into review.',
        fields: [
          { id: 'yearsActive', label: 'Years active', type: 'radio', options: [
            { value: 'lt1', label: 'Less than 1 year' },
            { value: '1to2', label: '1 to 2 years' },
            { value: 'gt2', label: 'More than 2 years' }
          ] }
        ]
      },
      annualRevenue: {
        id: 'annualRevenue',
        title: 'What is the annual revenue range?',
        help: 'A simple revenue band is enough for this demo to route the request intelligently.',
        fields: [
          { id: 'annualRevenue', label: 'Annual revenue', type: 'radio', options: [
            { value: 'lt50', label: 'Under $50k' },
            { value: '50to250', label: '$50k to $250k' },
            { value: 'gt250', label: '$250k+' }
          ] }
        ]
      },
      urgentNeed: {
        id: 'urgentNeed',
        title: 'Is the request time-sensitive?',
        help: 'Urgent requests are prioritized differently than general planning or exploratory applications.',
        fields: [
          { id: 'urgentNeed', label: 'Urgent need', type: 'radio', options: [
            { value: 'yes', label: 'Yes, it is time-sensitive' },
            { value: 'no', label: 'No, it is not urgent' }
          ] }
        ]
      },
      county: {
        id: 'county',
        title: 'Where is the applicant located?',
        help: 'Location helps determine the final routing and whether the request should be referred to a specialist team.',
        fields: [
          { id: 'county', label: 'Location', type: 'radio', options: [
            { value: 'metro', label: 'Metro area' },
            { value: 'rural', label: 'Rural or remote area' }
          ] }
        ]
      },
      npYearsActive: {
        id: 'npYearsActive',
        title: 'How long has the nonprofit been active?',
        help: 'This branch demonstrates a distinct eligibility path for nonprofits.',
        fields: [
          { id: 'npYearsActive', label: 'Years active', type: 'radio', options: [
            { value: 'lt1', label: 'Less than 1 year' },
            { value: '1to3', label: '1 to 3 years' },
            { value: 'gt3', label: 'More than 3 years' }
          ] }
        ]
      },
      servesYouth: {
        id: 'servesYouth',
        title: 'Does the organization primarily serve youth?',
        help: 'The seeded rules prioritize youth-serving nonprofits for one of the available outcomes.',
        fields: [
          { id: 'servesYouth', label: 'Serves youth', type: 'radio', options: [
            { value: 'yes', label: 'Yes' },
            { value: 'no', label: 'No' }
          ] }
        ]
      },
      householdIncome: {
        id: 'householdIncome',
        title: 'What best describes household income?',
        help: 'Income is often central to eligibility decisions and provides a useful branching example for the portfolio demo.',
        fields: [
          { id: 'householdIncome', label: 'Household income', type: 'radio', options: [
            { value: 'low', label: 'Lower income' },
            { value: 'mid', label: 'Middle income' },
            { value: 'high', label: 'Higher income' }
          ] }
        ]
      },
      veteran: {
        id: 'veteran',
        title: 'Does the applicant identify as a veteran?',
        help: 'This example uses a second factor to drive a final priority recommendation.',
        fields: [
          { id: 'veteran', label: 'Veteran status', type: 'radio', options: [
            { value: 'yes', label: 'Yes' },
            { value: 'no', label: 'No' }
          ] }
        ]
      }
    }
  end

  def labels
    {
      entityType: { small_business: 'Small business', nonprofit: 'Nonprofit organization', individual: 'Individual' },
      yearsActive: { lt1: 'Less than 1 year', '1to2': '1 to 2 years', gt2: 'More than 2 years' },
      annualRevenue: { lt50: 'Under $50k', '50to250': '$50k to $250k', gt250: '$250k+' },
      urgentNeed: { yes: 'Yes', no: 'No' },
      county: { metro: 'Metro area', rural: 'Rural or remote area' },
      npYearsActive: { lt1: 'Less than 1 year', '1to3': '1 to 3 years', gt3: 'More than 3 years' },
      servesYouth: { yes: 'Yes', no: 'No' },
      householdIncome: { low: 'Lower income', mid: 'Middle income', high: 'Higher income' },
      veteran: { yes: 'Yes', no: 'No' }
    }
  end

  def outcome_catalog
    [
      'Growth Line Fast-Track',
      'Foundational Review',
      'Community Priority Review',
      'General Program Review',
      'Priority Intake',
      'Veteran Services Referral'
    ]
  end

  def path_for(answers)
    path = []
    case answers['entityType']
    when 'small_business'
      path << 'Small business selected'
      path << case answers['yearsActive']
              when 'lt1' then 'Operating less than 1 year'
              when '1to2' then 'Operating 1 to 2 years'
              else 'Operating more than 2 years'
              end
      path << case answers['annualRevenue']
              when 'lt50' then 'Revenue under $50k'
              when '50to250' then 'Revenue between $50k and $250k'
              else 'Revenue above $250k'
              end
      path << (answers['urgentNeed'] == 'yes' ? 'Urgent request flagged' : 'Not urgent')
    when 'nonprofit'
      path << 'Nonprofit selected'
      path << case answers['npYearsActive']
              when 'lt1' then 'Operating less than 1 year'
              when '1to3' then 'Operating 1 to 3 years'
              else 'Operating more than 3 years'
              end
      path << (answers['servesYouth'] == 'yes' ? 'Youth-serving mission confirmed' : 'Not primarily youth-serving')
    else
      path << 'Individual selected'
      path << case answers['householdIncome']
              when 'low' then 'Lower-income household indicated'
              when 'mid' then 'Middle-income household indicated'
              else 'Higher-income household indicated'
              end
      path << (answers['veteran'] == 'yes' ? 'Veteran flag confirmed' : 'No veteran flag')
    end

    path << (answers['county'] == 'rural' ? 'Rural routing' : 'Metro routing available')
    path
  end

  def outcome_for(answers)
    case answers['entityType']
    when 'small_business'
      if answers['yearsActive'] == 'gt2' && answers['annualRevenue'] == 'gt250' && answers['urgentNeed'] == 'yes'
        ['Growth Line Fast-Track', 'Eligible', 'Established business with stronger revenue and an urgent request matched the fast-track route.']
      else
        ['Foundational Review', 'Review', 'Business request is better routed to guided review before a final recommendation.']
      end
    when 'nonprofit'
      if answers['servesYouth'] == 'yes' && answers['npYearsActive'] == 'gt3'
        ['Community Priority Review', 'Eligible', 'Youth-serving nonprofit with operating history qualified for the priority community review path.']
      else
        ['General Program Review', 'Review', 'Nonprofit request was routed to the general review queue for broader program matching.']
      end
    else
      if answers['veteran'] == 'yes'
        ['Veteran Services Referral', 'Referral', 'Veteran indicator triggered a referral recommendation tailored to that support track.']
      elsif answers['householdIncome'] == 'low'
        ['Priority Intake', 'Referral', 'Lower-income individual was routed to the priority intake path for quicker review.']
      else
        ['General Program Review', 'Review', 'Request was routed to the general review path based on the current screening answers.']
      end
    end
  end

  def build_submission(answers:, next_id: nil)
    outcome, status, reason = outcome_for(answers)
    {
      id: next_id,
      applicantName: answers['applicantName'].to_s.strip,
      applicantEmail: answers['applicantEmail'].to_s.strip,
      entityType: answers['entityType'],
      yearsActive: answers['yearsActive'],
      annualRevenue: answers['annualRevenue'],
      urgentNeed: answers['urgentNeed'],
      county: answers['county'],
      npYearsActive: answers['npYearsActive'],
      servesYouth: answers['servesYouth'],
      householdIncome: answers['householdIncome'],
      veteran: answers['veteran'],
      outcome: outcome,
      status: status,
      reason: reason,
      decisionPath: path_for(answers),
      createdAt: Time.now.strftime('%Y-%m-%d %H:%M')
    }.compact
  end
end
