import Foundation
import Combine

enum DateHelper {
    static func getStandardDateRange() -> (start: Date, end: Date) {
        let start = Date()
        let end = Calendar.current.date(byAdding: .year, value: 1, to: start) ?? start.addingTimeInterval(365*24*60*60)
        return (start, end)
    }
}

enum EALUnits {
    static let ewaUnits: [Unit] = [
        // NETP3-01
        Unit(
            code: "NETP3-01",  // Just the number - displayCode will add "NETP3-"
            eltCode: "EWA01",
            reference: "NETP3-01",
            title: "NETP3-01 Apply Health, Safety and Environmental Considerations",
            description: "Understanding and applying health and safety principles in electrical installation",
            unitType: .EWA,  // Critical: Must be .EWA for correct formatting
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Be able to apply relevant health and safety legislation in the workplace",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify which workplace health and safety procedures are relevant to the working environment and comply with their duties and obligations"),
                        PerformanceCriteria(code: "1.2", description: "Produce a risk assessment and method statement in accordance with organisational procedures"),
                        PerformanceCriteria(code: "1.3", description: "Work within the requirements of:"),
                        PerformanceCriteria(code: "1.3a", description: "Risk assessments"),
                        PerformanceCriteria(code: "1.3b", description: "Method statements"),
                        PerformanceCriteria(code: "1.3c", description: "Safe systems of work")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Be able to assess the work environment for hazards",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Identify unsafe situations and conditions and take remedial actions"),
                        PerformanceCriteria(code: "2.2", description: "Assess work environment & revise practices taking account of hazards:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials"),
                        PerformanceCriteria(code: "2.2b", description: "Tools"),
                        PerformanceCriteria(code: "2.2c", description: "Equipment"),
                        PerformanceCriteria(code: "2.3", description: "Identify any hazards which may present a high risk and report their presence to relevant persons"),
                        PerformanceCriteria(code: "2.4", description: "Apply measures to control health and safety hazards"),
                        PerformanceCriteria(code: "2.5", description: "Select and use correct personal protective equipment")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Be able to apply methods and procedures to ensure work on site is in accordance with health and safety legislation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Demonstrate personal conduct and behaviour within the workplace"),
                        PerformanceCriteria(code: "3.2", description: "Apply procedures to ensure safe use, maintenance & storage of equipment:"),
                        PerformanceCriteria(code: "3.2a", description: "Workplace policies (company and site)"),
                        PerformanceCriteria(code: "3.2b", description: "Supplier information"),
                        PerformanceCriteria(code: "3.2c", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "3.3", description: "Comply with hazard warning, mandatory instruction and prohibition notices"),
                        PerformanceCriteria(code: "3.4", description: "Apply procedures to ensure safety through correct use of guards and notices"),
                        PerformanceCriteria(code: "3.5", description: "Use access equipment correctly:"),
                        PerformanceCriteria(code: "3.5a", description: "Ladder"),
                        PerformanceCriteria(code: "3.5b", description: "Tower scaffold or MEWP"),
                        PerformanceCriteria(code: "3.5c", description: "Stepladder"),
                        PerformanceCriteria(code: "3.5d", description: "Platform")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Be able to work in accordance with environmental legislation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Apply procedures for safe handling, storing & disposal of hazardous materials:"),
                        PerformanceCriteria(code: "4.1a", description: "Environmental Protection Act"),
                        PerformanceCriteria(code: "4.1b", description: "Hazardous Waste Regulations"),
                        PerformanceCriteria(code: "4.1c", description: "Pollution Prevention and Control Act"),
                        PerformanceCriteria(code: "4.1d", description: "Control of Pollution Act"),
                        PerformanceCriteria(code: "4.1e", description: "Control of Noise at Work Regulations"),
                        PerformanceCriteria(code: "4.1f", description: "Environment Act")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),
        
        // NETP3-03
        Unit(
            code: "NETP3-03",  // Just the number
            eltCode: "EWA03",
            reference: "NETP3-03",
            title: "NETP3-03 Organise and Oversee the Electrical Work Environment",
            description: "Organizing and overseeing electrical work activities",
            unitType: .EWA,  // Changed from .performance to .EWA
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Be able to provide technical and functional information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Liaise with relevant people to evaluate the information they require to ensure that systems, equipment or components can be operated safely and effectively"),
                        PerformanceCriteria(code: "1.2", description: "Identify appropriate technical and functional information that is required for the work activity"),
                        PerformanceCriteria(code: "1.3", description: "Provide information in a timely, courteous, suitable and professional manner in accordance with organisational procedures and engineering standards"),
                        PerformanceCriteria(code: "1.1c", description: "Safety requirements"),
                        PerformanceCriteria(code: "1.2", description: "Identify required technical information"),
                        PerformanceCriteria(code: "1.3", description: "Provide information professionally"),
                        PerformanceCriteria(code: "1.4", description: "Follow organizational procedures")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Be able to oversee Health and Safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Produce, or revise generic, risk assessments and method statements, to cover their own work and others working the area (colleagues and other operatives) in accordance with their level of responsibility"),
                        PerformanceCriteria(code: "2.2", description: "Implement suitable procedures to confirm that work is being completed in accordance with health and safety legislation and industry standards"),
                        PerformanceCriteria(code: "2.3", description: "Ensure compliance with:"),
                        PerformanceCriteria(code: "2.3a", description: "Health and Safety legislation"),
                        PerformanceCriteria(code: "2.3b", description: "Industry standards"),
                        PerformanceCriteria(code: "2.3c", description: "Company procedures")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Be able to coordinate work activities",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Select effective procedures to ensure co-ordination with other workers/contractors, including steps to resolve issues which are outside the scope of their job role"),
                        PerformanceCriteria(code: "3.2", description: "Evaluate and apply communication techniques that are clear, accurate and appropriate to the situation"),
                        PerformanceCriteria(code: "3.3", description: "Demonstrate working effectively with colleagues to enhance performance"),
                        PerformanceCriteria(code: "3.4", description: "Report issues outside scope of responsibility")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Be able to organise and oversee work activities and operations",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Organise operatives by allocating duties and responsibilities to make the best use of their competence and skill"),
                        PerformanceCriteria(code: "4.2", description: "Monitor the work of operatives to ensure it is in accordance with:"),
                        PerformanceCriteria(code: "4.2a", description: "Industry working practices"),
                        PerformanceCriteria(code: "4.2b", description: "The programme of work"),
                        PerformanceCriteria(code: "4.2c", description: "Health and safety requirements"),
                        PerformanceCriteria(code: "4.2d", description: "Cost effectiveness"),
                        PerformanceCriteria(code: "4.2e", description: "Environmental considerations"),
                        PerformanceCriteria(code: "4.3", description: "Evaluate and apply appropriate procedures to correct issues that arise during work activities")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Be able to organise a programme for working on electrical systems and equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Produce a simple programme of work from the work specification, including requirements for the following:"),
                        PerformanceCriteria(code: "5.1a", description: "An estimation of the amount of time required for completion of the work"),
                        PerformanceCriteria(code: "5.1b", description: "Where liaison with other trades may be necessary"),
                        PerformanceCriteria(code: "5.2", description: "Communicate with others clearly and concisely"),
                        PerformanceCriteria(code: "5.3", description: "Assess situations when it is necessary to liaise with other relevant parties to resolve issues"),
                        
                        
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Be able to organise a programme for working on electrical systems and equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "6.1", description: "Organise the provision of resources (such as: materials fixings, plant, labour or tools)"),
                        PerformanceCriteria(code: "6.2", description: "Confirm that materials available are:"),
                        PerformanceCriteria(code: "6.2a", description: "The right type"),
                        PerformanceCriteria(code: "6.2b", description: "Fit for purpose"),
                        PerformanceCriteria(code: "6.2c", description: "In the correct quantity"),
                        PerformanceCriteria(code: "6.2d", description: "Suitable for work to be completed cost efficiently"),
                        PerformanceCriteria(code: "6.3", description: "Ensure that resources are undamaged at the point of delivery"),
                        PerformanceCriteria(code: "6.4", description: "Demonstrate effective measures which ensure the safe and effective storage of materials, tools and equipment in the work location")
                        
                        
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // NETP3-04
        Unit(
            code: "NETP3-04",
            eltCode: "EWA04",
            reference: "NETP3-04",
            title: "NETP3-04 Install Electrical Equipment",
            description: "Installing electrical systems and equipment",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Prepare to install wiring systems, enclosures and associated equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "04-1.1", description: "Assess and apply appropriate procedures to include:"),
                        PerformanceCriteria(code: "04-1.1a", description: "Adopting appropriate PPE"),
                        PerformanceCriteria(code: "04-1.1b", description: "Following a safe system of work"),
                        PerformanceCriteria(code: "04-1.1c", description: "Selecting appropriate tools/equipment for the task"),
                        PerformanceCriteria(code: "04-1.2", description: "Prepare to install wiring systems, enclosures & equipment:"),
                        PerformanceCriteria(code: "04-1.2a", description: "Confirm secure site storage facilities for tools, equipment, materials and components"),
                        PerformanceCriteria(code: "04-1.2b", description: "Select materials (equipment and components) in accordance with the installation specification"),
                        PerformanceCriteria(code: "04-1.2c", description: "Report any pre-work damage/defects to existing or building features, to the relevant person"),
                        PerformanceCriteria(code: "04-1.2d", description: "Confirm site readiness for installation work to begin"),
                        PerformanceCriteria(code: "04-1.2e", description: "Confirm authorisation for the installation work to start"),
                        PerformanceCriteria(code: "1.3", description: "Use documentation to confirm materials and equipment is correct quantity and free from damage"),
                        PerformanceCriteria(code: "1.4", description: "Ensure planned locations are compatible with other building services"),
                        PerformanceCriteria(code: "04-1.5", description: "Check the planned locations for the wiring system in terms of:"),
                        PerformanceCriteria(code: "04-1.5a", description: "Cosmetic appearance"),
                        PerformanceCriteria(code: "04-1.5b", description: "External influences")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Interpret appropriate information for installation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "04-2.1", description: "Use sources of information to enable the installation of wiring systems:"),
                        PerformanceCriteria(code: "04-2.1a", description: "Specifications"),
                        PerformanceCriteria(code: "04-2.1b", description: "Work schedules/programmes"),
                        PerformanceCriteria(code: "04-2.1c", description: "Manufacturer instructions"),
                        PerformanceCriteria(code: "04-2.1d", description: "Layout Drawings"),
                        PerformanceCriteria(code: "04-2.1e", description: "Other appropriate source of information (e.g BS 7671, other plans or diagrams 'approved documents', building regulations)")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Install wiring systems and equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Use appropriate measuring and marking out techniques"),
                        PerformanceCriteria(code: "04-3.2", description: "Install cables in accordance with BS7671:"),
                        PerformanceCriteria(code: "04-3.2a", description: "Single core (singles)"),
                        PerformanceCriteria(code: "04-3.2b", description: "Multicore insulated"),
                        PerformanceCriteria(code: "04-3.2c", description: "PVC - PVC flat profile cable"),
                        PerformanceCriteria(code: "04-3.2d", description: "MICC"),
                        PerformanceCriteria(code: "04-3.2e", description: "Fire performance"),
                        PerformanceCriteria(code: "04-3.2f", description: "SWA cable"),
                        PerformanceCriteria(code: "04-3.2g", description: "GSWB galvanised steel wire braid"),
                        PerformanceCriteria(code: "04-3.2h", description: "Data"),
                        PerformanceCriteria(code: "04-3.3", description: "Install the following in accordance with BS7671:"),
                        PerformanceCriteria(code: "04-3.3a", description: "PVC Conduit"),
                        PerformanceCriteria(code: "04-3.3b", description: "Metallic Conduit"),
                        PerformanceCriteria(code: "04-3.3c", description: "PVC Trunking"),
                        PerformanceCriteria(code: "04-3.3d", description: "Metallic Trunking"),
                        PerformanceCriteria(code: "04-3.3e", description: "Cable Tray"),
                        PerformanceCriteria(code: "04-3.3f", description: "Cable Basket"),
                        PerformanceCriteria(code: "04-3.3g", description: "Ladder systems"),
                        PerformanceCriteria(code: "04-3.3h", description: "Ducting"),
                        PerformanceCriteria(code: "04-3.3i", description: "Modular wiring systems"),
                        PerformanceCriteria(code: "04-3.3j", description: "Busbar systems or Powertrack"),
                        PerformanceCriteria(code: "04-3.4", description: "Install in accordance to installation spec, manufacturers' instructions:"),
                        PerformanceCriteria(code: "04-3.4a", description: "Isolators /switches"),
                        PerformanceCriteria(code: "04-3.4b", description: "Socket-outlets"),
                        PerformanceCriteria(code: "04-3.4c", description: "Distribution-boards / consumer control units"),
                        PerformanceCriteria(code: "04-3.4d", description: "Overcurrent protective devices"),
                        PerformanceCriteria(code: "04-3.4e", description: "Luminaires"),
                        PerformanceCriteria(code: "04-3.4f", description: "Data socket outlets"),
                        PerformanceCriteria(code: "04-3.4g", description: "Other appropriate equipment"),
                        PerformanceCriteria(code: "3.5", description: "Communicate with others professionally during installation"),
                        PerformanceCriteria(code: "3.6", description: "Dispose of waste materials in accordance with requirements")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Confirm quality of completed work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "04-4.1", description: "Ensure installed wiring system/s & enclosure/s meet specified requirements:"),
                        PerformanceCriteria(code: "04-4.1a", description: "Are the correct type and fit for purpose"),
                        PerformanceCriteria(code: "04-4.1b", description: "Are installed in accordance with BS 7671"),
                        PerformanceCriteria(code: "04-4.1c", description: "Meet the installation specification/other relevant plans/instructions"),
                        PerformanceCriteria(code: "04-4.1d", description: "Are installed in accordance with any relevant manufacturer instructions")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // NETP3-05
        Unit(
            code: "NETP3-05",
            eltCode: "EWA05",
            reference: "NETP3-05",
            title: "Terminate and Connect Conductors",
            description: "Terminating and connecting electrical conductors",
            unitType: .performance,
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation and Safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Evaluate and apply appropriate procedures to include:"),
                        PerformanceCriteria(code: "1.1a", description: "Selecting appropriate tools/equipment for termination and connection"),
                        PerformanceCriteria(code: "1.1b", description: "Adopting appropriate PPE"),
                        PerformanceCriteria(code: "1.1c", description: "Following safe system of work (risk assessment, method statement)"),
                        PerformanceCriteria(code: "1.2", description: "Assess/confirm it is safe to complete termination & connection:"),
                        PerformanceCriteria(code: "1.2a", description: "Checking for presence of supply/carrying out safe isolation"),
                        PerformanceCriteria(code: "1.2b", description: "Mechanical soundness of equipment to be connected to"),
                        PerformanceCriteria(code: "1.2c", description: "Checking for unsafe situations")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Termination and Connection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Terminate/connect cables/conductors according to instructions/BS7671:"),
                        PerformanceCriteria(code: "2.1a", description: "Single core cable (singles)"),
                        PerformanceCriteria(code: "2.1b", description: "Multicore insulated"),
                        PerformanceCriteria(code: "2.1c", description: "PVC/PVC flat profile cable"),
                        PerformanceCriteria(code: "2.1d", description: "MICC"),
                        PerformanceCriteria(code: "2.1e", description: "Fire performance"),
                        PerformanceCriteria(code: "2.1f", description: "SWA cable"),
                        PerformanceCriteria(code: "2.1g", description: "Data cables"),
                        PerformanceCriteria(code: "2.2", description: "Terminate/connect to electrical equipment according to instructions:"),
                        PerformanceCriteria(code: "2.2a", description: "Isolators/switches"),
                        PerformanceCriteria(code: "2.2b", description: "Socket-outlets"),
                        PerformanceCriteria(code: "2.2c", description: "Distribution boards/consumer units"),
                        PerformanceCriteria(code: "2.2d", description: "Luminaires"),
                        PerformanceCriteria(code: "2.2e", description: "Control equipment"),
                        PerformanceCriteria(code: "2.2f", description: "Data socket outlets")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Quality Checks",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Check terminations/connections meet requirements:"),
                        PerformanceCriteria(code: "3.1a", description: "Correct polarity"),
                        PerformanceCriteria(code: "3.1b", description: "Correct colour coding"),
                        PerformanceCriteria(code: "3.1c", description: "Correct sizing"),
                        PerformanceCriteria(code: "3.1d", description: "Secure connections"),
                        PerformanceCriteria(code: "3.1e", description: "Signs of damage"),
                        PerformanceCriteria(code: "3.2", description: "Ensure terminations/connections are mechanically and electrically sound")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // NETP3-06
        Unit(
            code: "NETP3-06",
            eltCode: "ELTP3-006",
            reference: "NETP3-06",
            title: "Inspecting, testing, commissioning and certifying electrotechnical systems",
            description: "Inspection, testing and commissioning of electrical installations",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation for Inspection and Testing",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Confirm scope of inspection and testing"),
                        PerformanceCriteria(code: "1.2", description: "Risk assess inspection and testing activities"),
                        PerformanceCriteria(code: "1.3", description: "Select appropriate test instruments"),
                        PerformanceCriteria(code: "1.4", description: "Verify test instruments are calibrated and functioning")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Inspection Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Complete visual inspection according to requirements"),
                        PerformanceCriteria(code: "2.2", description: "Record inspection results accurately"),
                        PerformanceCriteria(code: "2.3", description: "Identify and report non-compliant items")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Perform tests in correct sequence:"),
                        PerformanceCriteria(code: "3.1a", description: "Continuity testing"),
                        PerformanceCriteria(code: "3.1b", description: "Insulation resistance testing"),
                        PerformanceCriteria(code: "3.1c", description: "Polarity testing"),
                        PerformanceCriteria(code: "3.1d", description: "Earth fault loop impedance testing"),
                        PerformanceCriteria(code: "3.1e", description: "RCD testing"),
                        PerformanceCriteria(code: "3.1f", description: "Phase sequence testing"),
                        PerformanceCriteria(code: "3.2", description: "Record test results accurately"),
                        PerformanceCriteria(code: "3.3", description: "Compare results with required values")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Commissioning and Certification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Complete commissioning of installation"),
                        PerformanceCriteria(code: "4.2", description: "Complete required certification documentation"),
                        PerformanceCriteria(code: "4.3", description: "Provide handover information to client")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // ENTP3-07
        Unit(
            code: "NETP3-07",
            eltCode: "EWA07",
            reference: "NETP3-07",
            title: "Diagnose and Correct Electrical Faults",
            description: "Diagnosing and rectifying faults in electrical installations",
            unitType: .performance,
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Prepare to carry out fault diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Check it is safe to carry out fault diagnosis"),
                        PerformanceCriteria(code: "1.2", description: "Inform relevant personnel of the fault diagnosis work"),
                        PerformanceCriteria(code: "1.3", description: "Carry out the safe isolation procedure"),
                        PerformanceCriteria(code: "1.4", description: "Evaluate and apply appropriate methods to ensure safety")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Carry out fault diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Communicate effectively with relevant personnel to ascertain fault nature"),
                        PerformanceCriteria(code: "2.2", description: "Select and interpret appropriate documents for electrical systems"),
                        PerformanceCriteria(code: "2.3", description: "Assess and communicate potential disruption from fault diagnosis"),
                        PerformanceCriteria(code: "2.4", description: "Carry out relevant inspections analyzing findings"),
                        PerformanceCriteria(code: "2.5", description: "Confirm test instruments are fit for purpose and calibrated"),
                        PerformanceCriteria(code: "2.6", description: "Suitable diagnostic test to identify fault:"),
                        PerformanceCriteria(code: "2.6a", description: "Loss of supply"),
                        PerformanceCriteria(code: "2.6b", description: "Overload"),
                        PerformanceCriteria(code: "2.6c", description: "Short-circuit"),
                        PerformanceCriteria(code: "2.6d", description: "Earth fault"),
                        PerformanceCriteria(code: "2.6e", description: "Incorrect phase rotation"),
                        PerformanceCriteria(code: "2.6f", description: "High resistance joints/loose terminations"),
                        PerformanceCriteria(code: "2.6g", description: "Component, accessory or equipment faults"),
                        PerformanceCriteria(code: "2.6h", description: "Open circuit"),
                        PerformanceCriteria(code: "2.6i", description: "Signal faults"),
                        PerformanceCriteria(code: "2.7", description: "Use appropriate methods for locating faults:"),
                        PerformanceCriteria(code: "2.7a", description: "Using a logical approach"),
                        PerformanceCriteria(code: "2.7b", description: "Using safe working practices"),
                        PerformanceCriteria(code: "2.7c", description: "Interpretation of test readings"),
                        PerformanceCriteria(code: "2.8", description: "Use appropriate instruments for fault diagnosis:"),
                        PerformanceCriteria(code: "2.8a", description: "Voltage indicator"),
                        PerformanceCriteria(code: "2.8b", description: "Low resistance ohm meter"),
                        PerformanceCriteria(code: "2.8c", description: "Insulation resistance tester"),
                        PerformanceCriteria(code: "2.8d", description: "EFLI and PFC tester"),
                        PerformanceCriteria(code: "2.8e", description: "RCD tester"),
                        PerformanceCriteria(code: "2.8f", description: "Ammeter"),
                        PerformanceCriteria(code: "2.8g", description: "Phase rotation tester"),
                        PerformanceCriteria(code: "2.8h", description: "Other appropriate instrument")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Carry out fault rectification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Assess repairs/removals/replacements/implications to:"),
                        PerformanceCriteria(code: "3.1a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "3.1b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.2", description: "Perform fault correction procedures correctly and safely"),
                        PerformanceCriteria(code: "3.3", description: "Assess & verify replacement components & associated equipment maintain:"),
                        PerformanceCriteria(code: "3.3a", description: "Ease of access for future maintenance"),
                        PerformanceCriteria(code: "3.3b", description: "Compliance with relevant regulations"),
                        PerformanceCriteria(code: "3.3c", description: "Compliance with manufacturer's instructions/procedures")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // Add to ewaUnits array:
        Unit(
            code: "18ED3 02",  // Updated from BS7671-18
            eltCode: "BS7671",
            reference: "18ED3 02",
            title: "Requirements for Electrical Installations - IET Wiring Regulations 18th Edition",
            description: "Understanding and applying the IET Wiring Regulations BS7671:2018",
            unitType: .EWA,
            creditValue: 3,
            glh: 30,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "BS7671 Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Hold valid BS7671:2018 qualification certificate"),
                        PerformanceCriteria(code: "1.2", description: "Certificate must be within current amendment period")
                    ]
                )
            ],
            allowedAssessmentMethods: [.productEvidence]  // Using existing .productEvidence
        ),

        Unit(
            code: "QIT3-001",
            eltCode: "2391",
            reference: "QIT3-001",
            title: "Initial Verification and Certification of Electrical Installations",
            description: "Initial verification, testing and certification of electrical installations",
            unitType: .EWA,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Initial Verification Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Hold valid 2391-50 or equivalent qualification certificate"),
                        PerformanceCriteria(code: "1.2", description: "Certificate must be within current validity period")
                    ]
                )
            ],
            allowedAssessmentMethods: [.productEvidence]
        )
    ]
    static let nvqUnits: [Unit] = [
        // ELTK3 Knowledge Units (001-007)
        Unit(
            code: "ELTK3-001",
            eltCode: "1605-ELTK3-001", 
            reference: "ELTK3-001",
            title: "Understanding Health and Safety Legislation and Working Practices",
            description: "Knowledge of health and safety in electrical installation",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Health and Safety Legislation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand key health and safety legislation"),
                        PerformanceCriteria(code: "1.2", description: "Understand employer and employee responsibilities"),
                        PerformanceCriteria(code: "1.3", description: "Understand risk assessment requirements"),
                        PerformanceCriteria(code: "1.4", description: "Understand safe systems of work")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Safe Working Practices",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand safe working procedures"),
                        PerformanceCriteria(code: "2.2", description: "Understand use of PPE and safety equipment"),
                        PerformanceCriteria(code: "2.3", description: "Understand safe manual handling techniques"),
                        PerformanceCriteria(code: "2.4", description: "Understand workplace hazard identification")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Emergency Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Understand emergency procedures"),
                        PerformanceCriteria(code: "3.2", description: "Understand first aid requirements"),
                        PerformanceCriteria(code: "3.3", description: "Understand accident reporting procedures"),
                        PerformanceCriteria(code: "3.3", description: "Comply with hazard, warning, mandatory instruction and prohibition notices"),
                        PerformanceCriteria(code: "3.4", description: "Apply procedures to ensure the safety of the work location through the correct use of guards and notices    "),
                        PerformanceCriteria(code: "3.5", description: "Use access equipment correctly")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        // After ELTK3-001, add:

        Unit(
            code: "ELTK3-002",
            eltCode: "1605-ELTK3-002",
            reference: "ELTK3-002", 
            title: "Understanding Environmental Legislation, Working Practices and the Principles of Environmental Technology Systems",
            description: "Knowledge of environmental practices and technology systems",
            unitType: .knowledge,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Environmental Legislation and Practice",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand environmental legislation requirements"),
                        PerformanceCriteria(code: "1.2", description: "Understand environmental protection measures"),
                        PerformanceCriteria(code: "1.3", description: "Understand waste management procedures")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Environmental Technology Systems",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand principles of environmental technology systems:"),
                        PerformanceCriteria(code: "2.1a", description: "Solar photovoltaic"),
                        PerformanceCriteria(code: "2.1b", description: "Wind energy"),
                        PerformanceCriteria(code: "2.1c", description: "Micro hydro"),
                        PerformanceCriteria(code: "2.1d", description: "Heat pumps"),
                        PerformanceCriteria(code: "2.1e", description: "Grey water recycling"),
                        PerformanceCriteria(code: "2.1f", description: "Rainwater harvesting"),
                        PerformanceCriteria(code: "2.1g", description: "Biomass heating")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        
        Unit(
            code: "ELTK3-003",
            eltCode: "1605-ELTK3-003",
            reference: "ELTK3-003",
            title: "Understanding the Practices and Procedures for Overseeing and Organising the Work Environment",
            description: "Knowledge of work environment management",
            unitType: .knowledge,
            creditValue: 5,
            glh: 45,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Information and Communication",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand procedures for providing technical and functional information"),
                        PerformanceCriteria(code: "1.2", description: "Understand methods of liaising with relevant people"),
                        PerformanceCriteria(code: "1.3", description: "Understand importance of clear and accurate communication")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Work Organisation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand procedures for organizing work activities"),
                        PerformanceCriteria(code: "2.2", description: "Understand methods for coordinating work with others"),
                        PerformanceCriteria(code: "2.3", description: "Understand requirements for monitoring work quality")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Resource Management",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Understand procedures for managing resources"),
                        PerformanceCriteria(code: "3.2", description: "Understand methods for ensuring resource availability"),
                        PerformanceCriteria(code: "3.3", description: "Understand importance of efficient resource utilization")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-004",
            eltCode: "1605-ELTK3-004",
            reference: "ELTK3-004",
            title: "Installing wiring systems and enclosures for electrical systems",
            description: "Installation of electrical wiring systems",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation and Safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Ensure the health and safety of themselves and others within the work location"),
                        PerformanceCriteria(code: "1.2", description: "Identify and use suitable personal protective equipment throughout the completion of work activities"),
                        PerformanceCriteria(code: "1.3", description: "Complete preparatory work for the installation of electrical systems, enclosures and associated equipment, to include:"),
                        PerformanceCriteria(code: "1.3a", description: "Interpretation of installation specifications to produce material and equipment requisites"),
                        PerformanceCriteria(code: "1.3b", description: "Identification and selection of material, equipment and components which are compatible with the installation specification"),
                        PerformanceCriteria(code: "1.3c", description: "Identification of suitable methods, procedures and practices"),
                        PerformanceCriteria(code: "1.3d", description: "Confirmation of site readiness for installation work to begin"),
                        PerformanceCriteria(code: "1.3e", description: "Confirmation of secure site storage facilities for tools, equipment, materials and components"),
                        PerformanceCriteria(code: "1.3f", description: "Confirmation that safe isolation has been carried out (if appropriate) in accordance with regulatory requirements"),
                        PerformanceCriteria(code: "1.3g", description: "Completion of a risk assessment")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Documentation and Materials",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Use information and documentation that is current and relevant to the work required, including:"),
                        PerformanceCriteria(code: "2.1a", description: "Installation specifications"),
                        PerformanceCriteria(code: "2.1b", description: "Work schedules"),
                        PerformanceCriteria(code: "2.1c", description: "Work programmes"),
                        PerformanceCriteria(code: "2.1d", description: "Method statements"),
                        PerformanceCriteria(code: "2.1e", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "2.1f", description: "Regulatory documents (including current version of BS 7671 and relevant Guidance Notes)"),
                        PerformanceCriteria(code: "2.2", description: "Use documentation to confirm that materials and equipment is of the correct quantity and is free from damage, including:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials schedules"),
                        PerformanceCriteria(code: "2.2b", description: "Plant and equipment schedules"),
                        PerformanceCriteria(code: "2.2c", description: "Operating instructions"),
                        PerformanceCriteria(code: "2.2d", description: "Tools and instruments")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Documentation and Authorization",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Use appropriate procedures to record:"),
                        PerformanceCriteria(code: "3.1a", description: "Contract variations"),
                        PerformanceCriteria(code: "3.1b", description: "Site instructions"),
                        PerformanceCriteria(code: "3.1c", description: "Site events/diary"),
                        PerformanceCriteria(code: "3.2", description: "Demonstrate that authorisation has been obtained from the relevant person(s) prior to commencement of the work, including:"),
                        PerformanceCriteria(code: "3.2a", description: "Other workers"),
                        PerformanceCriteria(code: "3.2b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.2c", description: "Public (If appropriate)"),
                        PerformanceCriteria(code: "3.3", description: "Produce a record of any pre work damage or defects to existing equipment or building features, and report to the relevant person (Customer; Client; Site Manager; Line Manager)")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Verify Installation Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Verify the compatibility of the electrical supply to the requirements of the installation specification"),
                        PerformanceCriteria(code: "4.2", description: "Identify the earthing arrangement for the electrical installation")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Installation Planning and Layout",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Ensure that the planned locations for the wiring system(s) and its associated equipment are compatible with other site services requirements"),
                        PerformanceCriteria(code: "5.2", description: "Use different measuring and marking out techniques which are appropriate to the wiring system, wiring enclosure and/or associated equipment that is being installed"),
                        PerformanceCriteria(code: "5.3", description: "Ensure that the planned locations are visually acceptable and in accordance with the installation specification")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTK3-004A",
            eltCode: "1605-ELTK3-004A",
            reference: "ELTK3-004A",
            title: "Understanding the Requirements for Installing Wiring Systems",
            description: "Knowledge of wiring system installation",
            unitType: .knowledge,
            creditValue: 5,
            glh: 45,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Wiring Systems",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand types and applications of wiring systems"),
                        PerformanceCriteria(code: "1.2", description: "Understand installation methods for different wiring systems"),
                        PerformanceCriteria(code: "1.3", description: "Understand requirements of BS7671 for wiring systems")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Installation Methods",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand cable selection and sizing"),
                        PerformanceCriteria(code: "2.2", description: "Understand containment systems"),
                        PerformanceCriteria(code: "2.3", description: "Understand fixing and support methods"),
                        PerformanceCriteria(code: "2.4", description: "Understand protection requirements")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing and Verification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Understand testing requirements for wiring systems"),
                        PerformanceCriteria(code: "3.2", description: "Understand inspection procedures"),
                        PerformanceCriteria(code: "3.3", description: "Understand documentation requirements")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Safety Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Understand safe isolation procedures"),
                        PerformanceCriteria(code: "4.2", description: "Understand earthing and bonding requirements"),
                        PerformanceCriteria(code: "4.3", description: "Understand protection against electric shock"),
                        PerformanceCriteria(code: "4.4", description: "Understand fire protection requirements")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-005",
            eltCode: "1605-ELTK3-005",
            reference: "ELTK3-005",
            title: "Understanding the Practices and Procedures for the Termination and Connection of Conductors, Cables and Cords in Electrical Systems",
            description: "Knowledge of electrical terminations and connections",
            unitType: .knowledge,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Cable and Conductor Types",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand different types of cables and conductors"),
                        PerformanceCriteria(code: "1.2", description: "Understand cable sizing and selection criteria"),
                        PerformanceCriteria(code: "1.3", description: "Understand cable ratings and current carrying capacity")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Termination Methods",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand termination techniques for:"),
                        PerformanceCriteria(code: "2.1a", description: "Single core cables"),
                        PerformanceCriteria(code: "2.1b", description: "Multicore cables"),
                        PerformanceCriteria(code: "2.1c", description: "Steel wire armoured cables"),
                        PerformanceCriteria(code: "2.1d", description: "Mineral insulated cables"),
                        PerformanceCriteria(code: "2.2", description: "Understand gland types and selection"),
                        PerformanceCriteria(code: "2.3", description: "Understand earthing requirements")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Connection Methods",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Understand connection methods for:"),
                        PerformanceCriteria(code: "3.1a", description: "Distribution boards"),
                        PerformanceCriteria(code: "3.1b", description: "Consumer units"),
                        PerformanceCriteria(code: "3.1c", description: "Wiring accessories"),
                        PerformanceCriteria(code: "3.2", description: "Understand torque settings"),
                        PerformanceCriteria(code: "3.3", description: "Understand connection security requirements")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Testing and Verification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Understand testing requirements for terminations"),
                        PerformanceCriteria(code: "4.2", description: "Understand continuity testing procedures"),
                        PerformanceCriteria(code: "4.3", description: "Understand polarity testing procedures"),
                        PerformanceCriteria(code: "4.4", description: "Understand insulation resistance testing procedures")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-006",
            eltCode: "1605-ELTK3-006",
            reference: "ELTK3-006",
            title: "Understanding the Inspection, Testing, Commissioning and Certification of Electrical Systems",
            description: "Knowledge of electrical system verification",
            unitType: .knowledge,
            creditValue: 5,
            glh: 45,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Inspection Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand requirements for initial verification"),
                        PerformanceCriteria(code: "1.2", description: "Understand inspection procedures and methods"),
                        PerformanceCriteria(code: "1.3", description: "Understand documentation requirements for inspection")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Testing Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand testing requirements and sequences"),
                        PerformanceCriteria(code: "2.2", description: "Understand test instrument selection and use"),
                        PerformanceCriteria(code: "2.3", description: "Understand interpretation of test results")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Commissioning and Certification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Understand commissioning procedures"),
                        PerformanceCriteria(code: "3.2", description: "Understand certification requirements"),
                        PerformanceCriteria(code: "3.3", description: "Understand handover procedures")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-007",
            eltCode: "1605-ELTK3-007",
            reference: "ELTK3-007",
            title: "Understanding the principles, practices and legislation for diagnosing and correcting electrical faults",
            description: "Knowledge and understanding of electrical fault diagnosis and correction",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Understand safe isolation procedures and implications",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Specify and undertake correct procedure for safe isolation:"),
                        PerformanceCriteria(code: "1.1a", description: "Assessment of safe working practices"),
                        PerformanceCriteria(code: "1.1b", description: "Correct identification of circuits to be isolated"),
                        PerformanceCriteria(code: "1.1c", description: "Selection of suitable points of isolation"),
                        PerformanceCriteria(code: "1.1d", description: "Selection of correct test and proving instruments"),
                        PerformanceCriteria(code: "1.1e", description: "Use of correct testing methods"),
                        PerformanceCriteria(code: "1.1f", description: "Selection of locking devices for securing isolation"),
                        PerformanceCriteria(code: "1.1g", description: "Use of correct warning notices"),
                        PerformanceCriteria(code: "1.1h", description: "Correct sequence for isolating circuits"),
                        PerformanceCriteria(code: "1.2", description: "State implications of carrying out safe isolations to:"),
                        PerformanceCriteria(code: "1.2a", description: "Other personnel"),
                        PerformanceCriteria(code: "1.2b", description: "Customers/clients"),
                        PerformanceCriteria(code: "1.2c", description: "Public"),
                        PerformanceCriteria(code: "1.2d", description: "Building systems (loss of supply)"),
                        PerformanceCriteria(code: "1.3", description: "State implications of not carrying out safe isolations to:"),
                        PerformanceCriteria(code: "1.3a", description: "Self"),
                        PerformanceCriteria(code: "1.3b", description: "Other personnel"),
                        PerformanceCriteria(code: "1.3c", description: "Customers/clients"),
                        PerformanceCriteria(code: "1.3d", description: "Public"),
                        PerformanceCriteria(code: "1.3e", description: "Building systems (Presence of supply)"),
                        PerformanceCriteria(code: "1.4", description: "Identify Health and Safety requirements for:"),
                        PerformanceCriteria(code: "1.4a", description: "Working in accordance with risk assessments/permits"),
                        PerformanceCriteria(code: "1.4b", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "1.4c", description: "Safe use of measuring instruments"),
                        PerformanceCriteria(code: "1.4d", description: "Provision and use of PPE")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Understand reporting and recording requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "State procedures for reporting and recording fault diagnosis work"),
                        PerformanceCriteria(code: "2.2", description: "State procedures for informing relevant persons"),
                        PerformanceCriteria(code: "2.3", description: "Explain importance of clear and courteous communication")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Understand fault diagnosis procedures and symptoms",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Specify safe working procedures including:"),
                        PerformanceCriteria(code: "3.1a", description: "Effective communication with others"),
                        PerformanceCriteria(code: "3.1b", description: "Use of barriers"),
                        PerformanceCriteria(code: "3.1c", description: "Positioning of notices"),
                        PerformanceCriteria(code: "3.1d", description: "Safe isolation"),
                        PerformanceCriteria(code: "3.2", description: "Interpret logical stages of fault diagnosis:"),
                        PerformanceCriteria(code: "3.2a", description: "Identification of symptoms"),
                        PerformanceCriteria(code: "3.2b", description: "Collection and analysis of data"),
                        PerformanceCriteria(code: "3.2c", description: "Use of information sources"),
                        PerformanceCriteria(code: "3.2d", description: "Maintenance records"),
                        PerformanceCriteria(code: "3.2e", description: "Experience (personal and others)"),
                        PerformanceCriteria(code: "3.2f", description: "Checking and testing"),
                        PerformanceCriteria(code: "3.2g", description: "Interpreting results"),
                        PerformanceCriteria(code: "3.2h", description: "Fault correction"),
                        PerformanceCriteria(code: "3.2i", description: "Functional testing"),
                        PerformanceCriteria(code: "3.2j", description: "Restoration")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Understand testing procedures and instruments",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "State dangers of electricity in fault diagnosis"),
                        PerformanceCriteria(code: "4.2", description: "Describe how to identify supply voltages"),
                        PerformanceCriteria(code: "4.3", description: "Select correct test instruments:"),
                        PerformanceCriteria(code: "4.3a", description: "Voltage indicator"),
                        PerformanceCriteria(code: "4.3b", description: "Low resistance ohm meter"),
                        PerformanceCriteria(code: "4.3c", description: "Insulation resistance testers"),
                        PerformanceCriteria(code: "4.3d", description: "EFLI and PFC tester"),
                        PerformanceCriteria(code: "4.3e", description: "RCD tester"),
                        PerformanceCriteria(code: "4.3f", description: "Tong tester/clamp on ammeter"),
                        PerformanceCriteria(code: "4.3g", description: "Phase sequence tester")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Understand fault correction procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Identify factors affecting fault correction:"),
                        PerformanceCriteria(code: "5.1a", description: "Cost"),
                        PerformanceCriteria(code: "5.1b", description: "Availability of resources"),
                        PerformanceCriteria(code: "5.1c", description: "Down time"),
                        PerformanceCriteria(code: "5.1d", description: "Legal responsibilities"),
                        PerformanceCriteria(code: "5.1e", description: "Access to systems"),
                        PerformanceCriteria(code: "5.1f", description: "Emergency supplies"),
                        PerformanceCriteria(code: "5.1g", description: "Client demands"),
                        PerformanceCriteria(code: "5.2", description: "Specify functional testing procedures:"),
                        PerformanceCriteria(code: "5.2a", description: "Continuity"),
                        PerformanceCriteria(code: "5.2b", description: "Insulation resistance"),
                        PerformanceCriteria(code: "5.2c", description: "Polarity"),
                        PerformanceCriteria(code: "5.2d", description: "Earth fault loop impedance"),
                        PerformanceCriteria(code: "5.2e", description: "RCD operation"),
                        PerformanceCriteria(code: "5.2f", description: "Current and voltage values"),
                        PerformanceCriteria(code: "5.2g", description: "Phase sequencing")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        // After all ELTK3 units, add ELTP3-001:
        Unit(
            code: "ELTK3-008",
            eltCode: "1605-ELTK3-008",
            reference: "ELTK3-008",
            title: "Understanding the electrical principles associated with the design, building, installation and maintenance of electrical equipment and systems",
            description: "Knowledge and understanding of mathematical principles which are appropriate to electrical installation, maintenance and design ",
            unitType: .knowledge,
            creditValue: 12,
            glh: 106,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Understand mathematical principles which are appropriate to electrical installation, maintenance and design work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1a", description: "Identify and apply appropriate mathematical principles which are relevant to electrotechnical work tasks including Fractions and percentages"),
                        PerformanceCriteria(code: "1.1b", description: "Algebra"),
                        PerformanceCriteria(code: "1.1c", description: "Indices"),
                        PerformanceCriteria(code: "1.1d", description: "Powers of 10"),
                        PerformanceCriteria(code: "1.1e", description: "Transposition"),
                        PerformanceCriteria(code: "1.1f", description: "Triangles and trigonometry"),
                        PerformanceCriteria(code: "1.1g", description: "Use of correct warning notices"),
                        PerformanceCriteria(code: "1.1h", description: "Statistics"),
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Understand standard units of measurement used in electrical installation, maintenance and design work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1a", description: "Identify and use internationally recognised (SI) units of measurement for general variables including Length"),
                        PerformanceCriteria(code: "2.1b", description: "Area"),
                        PerformanceCriteria(code: "2.1c", description: "Volume"),
                        PerformanceCriteria(code: "2.1d", description: "Mass"),
                        PerformanceCriteria(code: "2.1e", description: "Density"),
                        PerformanceCriteria(code: "2.1f", description: "Time"),
                        PerformanceCriteria(code: "2.1g", description: "Temperature"),
                        PerformanceCriteria(code: "2.1h", description: "Velocity"),
                        PerformanceCriteria(code: "2.2a", description: "Identify and determine values of basic SI units which apply specifically to electrical variables, including Resistance"),
                        PerformanceCriteria(code: "2.2b", description: "Public"),
                        PerformanceCriteria(code: "2.2c", description: "Building systems (Presence of supply)"),
                        PerformanceCriteria(code: "2.2d", description: "Identify Health and Safety requirements for:"),
                        PerformanceCriteria(code: "2.2e", description: "Working in accordance with risk assessments/permits"),
                        PerformanceCriteria(code: "2.2f", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2g", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2h", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2i", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2j", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2k", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2l", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2m", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.2n", description: "Safe use of tools and equipment"),
                        PerformanceCriteria(code: "2.3a", description: "Identify appropriate electrical instruments for the measurement and calculation of different electrical values including Resistance"),
                        PerformanceCriteria(code: "2.2b", description: "Power"),
                        PerformanceCriteria(code: "2.2c", description: "Frequency"),
                        PerformanceCriteria(code: "2.2d", description: "Current"),
                        PerformanceCriteria(code: "2.2e", description: "Voltage"),
                        PerformanceCriteria(code: "2.2f", description: " Energy"),
                        PerformanceCriteria(code: "2.2g", description: "Impedance"),
                        
                        PerformanceCriteria(code: "3.1a", description: "Specify what is meant by the following : Mass"),
                        PerformanceCriteria(code: "3.1b", description: "Weight"),
                        PerformanceCriteria(code: "3.2a", description: "Explain the principles of basic mechanics as they apply to: Levers"),
                        PerformanceCriteria(code: "3.2b", description: "Gears"),
                        PerformanceCriteria(code: "3.2c", description: "Pulleys"),
                        PerformanceCriteria(code: "3.3a", description: "Describe the main principles of the following and their inter-relationships: Force"),
                        PerformanceCriteria(code: "3.3b", description: "Work"),
                        PerformanceCriteria(code: "3.3c", description: "Energy (kinetic and potential)"),
                        PerformanceCriteria(code: "3.3d", description: "Power"),
                        PerformanceCriteria(code: "3.3e", description: "Efficiency"),
                        PerformanceCriteria(code: "3.4a", description: "Calculate values of electrical: Energy"),
                        

                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Understand reporting and recording requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "State procedures for reporting and recording fault diagnosis work"),
                        PerformanceCriteria(code: "2.2", description: "State procedures for informing relevant persons"),
                        PerformanceCriteria(code: "2.3", description: "Explain importance of clear and courteous communication")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Understand fault diagnosis procedures and symptoms",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Specify safe working procedures including:"),
                        PerformanceCriteria(code: "3.1a", description: "Effective communication with others"),
                        PerformanceCriteria(code: "3.1b", description: "Use of barriers"),
                        PerformanceCriteria(code: "3.1c", description: "Positioning of notices"),
                        PerformanceCriteria(code: "3.1d", description: "Safe isolation"),
                        PerformanceCriteria(code: "3.2", description: "Interpret logical stages of fault diagnosis:"),
                        PerformanceCriteria(code: "3.2a", description: "Identification of symptoms"),
                        PerformanceCriteria(code: "3.2b", description: "Collection and analysis of data"),
                        PerformanceCriteria(code: "3.2c", description: "Use of information sources"),
                        PerformanceCriteria(code: "3.2d", description: "Maintenance records"),
                        PerformanceCriteria(code: "3.2e", description: "Experience (personal and others)"),
                        PerformanceCriteria(code: "3.2f", description: "Checking and testing"),
                        PerformanceCriteria(code: "3.2g", description: "Interpreting results"),
                        PerformanceCriteria(code: "3.2h", description: "Fault correction"),
                        PerformanceCriteria(code: "3.2i", description: "Functional testing"),
                        PerformanceCriteria(code: "3.2j", description: "Restoration")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Understand testing procedures and instruments",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "State dangers of electricity in fault diagnosis"),
                        PerformanceCriteria(code: "4.2", description: "Describe how to identify supply voltages"),
                        PerformanceCriteria(code: "4.3", description: "Select correct test instruments:"),
                        PerformanceCriteria(code: "4.3a", description: "Voltage indicator"),
                        PerformanceCriteria(code: "4.3b", description: "Low resistance ohm meter"),
                        PerformanceCriteria(code: "4.3c", description: "Insulation resistance testers"),
                        PerformanceCriteria(code: "4.3d", description: "EFLI and PFC tester"),
                        PerformanceCriteria(code: "4.3e", description: "RCD tester"),
                        PerformanceCriteria(code: "4.3f", description: "Tong tester/clamp on ammeter"),
                        PerformanceCriteria(code: "4.3g", description: "Phase sequence tester")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Understand fault correction procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Identify factors affecting fault correction:"),
                        PerformanceCriteria(code: "5.1a", description: "Cost"),
                        PerformanceCriteria(code: "5.1b", description: "Availability of resources"),
                        PerformanceCriteria(code: "5.1c", description: "Down time"),
                        PerformanceCriteria(code: "5.1d", description: "Legal responsibilities"),
                        PerformanceCriteria(code: "5.1e", description: "Access to systems"),
                        PerformanceCriteria(code: "5.1f", description: "Emergency supplies"),
                        PerformanceCriteria(code: "5.1g", description: "Client demands"),
                        PerformanceCriteria(code: "5.2", description: "Specify functional testing procedures:"),
                        PerformanceCriteria(code: "5.2a", description: "Continuity"),
                        PerformanceCriteria(code: "5.2b", description: "Insulation resistance"),
                        PerformanceCriteria(code: "5.2c", description: "Polarity"),
                        PerformanceCriteria(code: "5.2d", description: "Earth fault loop impedance"),
                        PerformanceCriteria(code: "5.2e", description: "RCD operation"),
                        PerformanceCriteria(code: "5.2f", description: "Current and voltage values"),
                        PerformanceCriteria(code: "5.2g", description: "Phase sequencing")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        
        
        
        Unit(
            code: "ELTP3-001",
            eltCode: "1605-ELTP3-001",
            reference: "ELTP3-001",
            title: "Applying health and safety legislation and working practices",
            description: "Installing and maintaining electrotechnical systems and equipment",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Apply relevant health and safety legislation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify which workplace health and safety procedures are relevant"),
                        PerformanceCriteria(code: "1.2", description: "Produce risk assessment and method statement in accordance with procedures"),
                        PerformanceCriteria(code: "1.3", description: "Work within the requirements of:"),
                        PerformanceCriteria(code: "1.3a", description: "Risk assessments"),
                        PerformanceCriteria(code: "1.3b", description: "Method statements"),
                        PerformanceCriteria(code: "1.3c", description: "Safe systems of work")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Assess the work environment for hazards",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Identify unsafe situations and conditions and take remedial actions"),
                        PerformanceCriteria(code: "2.2", description: "Assess work environment & revise practices for hazards from:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials"),
                        PerformanceCriteria(code: "2.2b", description: "Tools"),
                        PerformanceCriteria(code: "2.2c", description: "Equipment"),
                        PerformanceCriteria(code: "2.3", description: "Report high risk hazards to relevant persons"),
                        PerformanceCriteria(code: "2.4", description: "Apply measures to control health and safety hazards"),
                        PerformanceCriteria(code: "2.5", description: "Select and use correct personal protective equipment")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Apply methods and procedures for safe work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Demonstrate personal conduct and behaviour around the workplace"),
                        PerformanceCriteria(code: "3.2", description: "Apply procedures for safe use, maintenance & storage as per:"),
                        PerformanceCriteria(code: "3.2a", description: "Workplace policies (company and site)"),
                        PerformanceCriteria(code: "3.2b", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "3.2c", description: "Supplier information")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Apply procedures for accidents and emergencies",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Follow correct procedures in event of injury to self or others:"),
                        PerformanceCriteria(code: "4.1a", description: "Basic first aid procedures"),
                        PerformanceCriteria(code: "4.1b", description: "Notification of emergency services"),
                        PerformanceCriteria(code: "4.1c", description: "Reporting of incidents")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3-002",
            eltCode: "1605-ELTP3-002",
            reference: "ELTP3-002",
            title: "Applying environmental legislation, working practices and principles",
            description: "Environmental technology systems application",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Apply Environmental Protection Measures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Apply environmental protection measures in the workplace"),
                        PerformanceCriteria(code: "1.2", description: "Implement waste management procedures"),
                        PerformanceCriteria(code: "1.3", description: "Follow environmental legislation requirements")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Handle and Store Materials",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Handle and store materials and equipment in accordance with:"),
                        PerformanceCriteria(code: "2.1a", description: "Environmental Protection Act"),
                        PerformanceCriteria(code: "2.1b", description: "The Hazardous Waste Regulations"),
                        PerformanceCriteria(code: "2.1c", description: "Control of Pollution Act"),
                        PerformanceCriteria(code: "2.1d", description: "The Control of Noise at Work Regulations"),
                        PerformanceCriteria(code: "2.1e", description: "The Waste Electrical and Electronic Equipment Regulations")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Environmental Technology Systems",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Provide information on environmental technology systems:"),
                        PerformanceCriteria(code: "3.1a", description: "Solar photovoltaic"),
                        PerformanceCriteria(code: "3.1b", description: "Wind energy"),
                        PerformanceCriteria(code: "3.1c", description: "Micro hydro"),
                        PerformanceCriteria(code: "3.1d", description: "Heat pumps"),
                        PerformanceCriteria(code: "3.1e", description: "Grey water recycling"),
                        PerformanceCriteria(code: "3.1f", description: "Rainwater harvesting"),
                        PerformanceCriteria(code: "3.1g", description: "Biomass heating"),
                        PerformanceCriteria(code: "3.1h", description: "Solar thermal hot water heating"),
                        PerformanceCriteria(code: "3.1i", description: "Combined heat and power (CHP) including micro CHP")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3-003",
            eltCode: "1605-ELTP3-003",
            reference: "ELTP3-003",
            title: "Overseeing and Organising the Work Environment",
            description: "Electrical installation",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Be able to provide technical and functional information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify relevant people that need technical/functional information"),
                        PerformanceCriteria(code: "1.2", description: "Identify additional information required"),
                        PerformanceCriteria(code: "1.2a", description: "Health and safety information"),
                        PerformanceCriteria(code: "1.2b", description: "Isolation procedures"),
                        PerformanceCriteria(code: "1.2c", description: "Contact details for further advice"),
                        PerformanceCriteria(code: "1.3", description: "Liaise with relevant people to determine information needs"),
                        PerformanceCriteria(code: "1.4", description: "Identify appropriate technical and functional information"),
                        PerformanceCriteria(code: "1.5", description: "Provide information professionally and according to procedures")
                    ]
                ),
                // ... continue with LOs 2-4
            ], allowedAssessmentMethods: [.directObservation, .productEvidence]  // Fixed: Added proper assessment methods
        ),

        Unit(
            code: "ELTP3-004",
            eltCode: "1605-ELTP3-004",
            reference: "ELTP3-004",
            title: "Installing wiring systems and enclosures for electrical systems",
            description: "Installation of electrical wiring systems",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation and Safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Ensure the health and safety of themselves and others within the work location"),
                        PerformanceCriteria(code: "1.2", description: "Identify and use suitable personal protective equipment throughout the completion of work activities"),
                        PerformanceCriteria(code: "1.3", description: "Complete preparatory work for the installation of electrical systems, enclosures and associated equipment, to include:"),
                        PerformanceCriteria(code: "1.3a", description: "Interpretation of installation specifications to produce material and equipment requisites"),
                        PerformanceCriteria(code: "1.3b", description: "Identification and selection of material, equipment and components which are compatible with the installation specification"),
                        PerformanceCriteria(code: "1.3c", description: "Identification of suitable methods, procedures and practices"),
                        PerformanceCriteria(code: "1.3d", description: "Confirmation of site readiness for installation work to begin"),
                        PerformanceCriteria(code: "1.3e", description: "Confirmation of secure site storage facilities for tools, equipment, materials and components"),
                        PerformanceCriteria(code: "1.3f", description: "Confirmation that safe isolation has been carried out (if appropriate) in accordance with regulatory requirements"),
                        PerformanceCriteria(code: "1.3g", description: "Completion of a risk assessment")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Documentation and Materials",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Use information and documentation that is current and relevant to the work required, including:"),
                        PerformanceCriteria(code: "2.1a", description: "Installation specifications"),
                        PerformanceCriteria(code: "2.1b", description: "Work schedules"),
                        PerformanceCriteria(code: "2.1c", description: "Work programmes"),
                        PerformanceCriteria(code: "2.1d", description: "Method statements"),
                        PerformanceCriteria(code: "2.1e", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "2.1f", description: "Regulatory documents (including current version of BS 7671 and relevant Guidance Notes)"),
                        PerformanceCriteria(code: "2.2", description: "Use documentation to confirm that materials and equipment is of the correct quantity and is free from damage, including:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials schedules"),
                        PerformanceCriteria(code: "2.2b", description: "Plant and equipment schedules"),
                        PerformanceCriteria(code: "2.2c", description: "Operating instructions"),
                        PerformanceCriteria(code: "2.2d", description: "Tools and instruments")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Documentation and Authorization",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Use appropriate procedures to record:"),
                        PerformanceCriteria(code: "3.1a", description: "Contract variations"),
                        PerformanceCriteria(code: "3.1b", description: "Site instructions"),
                        PerformanceCriteria(code: "3.1c", description: "Site events/diary"),
                        PerformanceCriteria(code: "3.2", description: "Demonstrate that authorisation has been obtained from the relevant person(s) prior to commencement of the work, including:"),
                        PerformanceCriteria(code: "3.2a", description: "Other workers"),
                        PerformanceCriteria(code: "3.2b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.2c", description: "Public (If appropriate)"),
                        PerformanceCriteria(code: "3.3", description: "Produce a record of any pre work damage or defects to existing equipment or building features, and report to the relevant person (Customer; Client; Site Manager; Line Manager)")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Verify Installation Requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Verify the compatibility of the electrical supply to the requirements of the installation specification"),
                        PerformanceCriteria(code: "4.2", description: "Identify the earthing arrangement for the electrical installation")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Installation Planning and Layout",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Ensure that the planned locations for the wiring system(s) and its associated equipment are compatible with other site services requirements"),
                        PerformanceCriteria(code: "5.2", description: "Use different measuring and marking out techniques which are appropriate to the wiring system, wiring enclosure and/or associated equipment that is being installed"),
                        PerformanceCriteria(code: "5.3", description: "Ensure that the planned locations are visually acceptable and in accordance with the installation specification")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3-005",
            eltCode: "1605-ELTP3-005",
            reference: "ELTP3-005",
            title: "Terminating and connecting conductors, cables and flexible cords in electrical systems",
            description: "Installation of electrical wiring and components",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation and Safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures"),
                        PerformanceCriteria(code: "1.2", description: "Select appropriate tools and equipment"),
                        PerformanceCriteria(code: "1.3", description: "Verify materials are correct and undamaged"),
                        PerformanceCriteria(code: "1.4", description: "Confirm work area is safe and ready")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Cable Termination and Connection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Terminate and connect cables according to specifications:"),
                        PerformanceCriteria(code: "2.1a", description: "Single core cable"),
                        PerformanceCriteria(code: "2.1b", description: "Multicore cable"),
                        PerformanceCriteria(code: "2.1c", description: "PVC/PVC flat profile cable"),
                        PerformanceCriteria(code: "2.1d", description: "MICC cable"),
                        PerformanceCriteria(code: "2.1e", description: "Fire performance cable"),
                        PerformanceCriteria(code: "2.1f", description: "SWA cable"),
                        PerformanceCriteria(code: "2.1g", description: "Data cables")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Equipment Connection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.2", description: "Connect to electrical equipment according to specifications:"),
                        PerformanceCriteria(code: "2.2a", description: "Isolators and switches"),
                        PerformanceCriteria(code: "2.2b", description: "Socket-outlets"),
                        PerformanceCriteria(code: "2.2c", description: "Distribution-boards"),
                        PerformanceCriteria(code: "2.2d", description: "Consumer units"),
                        PerformanceCriteria(code: "2.2e", description: "Luminaires"),
                        PerformanceCriteria(code: "2.2f", description: "Earthing terminals"),
                        PerformanceCriteria(code: "2.2g", description: "Control panels"),
                        PerformanceCriteria(code: "2.2h", description: "Electric motors and their control equipment"),
                        PerformanceCriteria(code: "2.2i", description: "Auxiliary equipment (e.g. heating system components)"),
                        PerformanceCriteria(code: "2.2j", description: "Data socket outlets"),
                        PerformanceCriteria(code: "2.3", description: "Terminate and connect conductors and cables using the following techniques:"),
                        PerformanceCriteria(code: "2.3a", description: "Screwing"),
                        PerformanceCriteria(code: "2.3b", description: "Crimping"),
                        PerformanceCriteria(code: "2.3c", description: "Soldering"),
                        PerformanceCriteria(code: "2.3d", description: "Non-screw compression")


                        

                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing and Documentation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Ensure that terminations and connections are electrically and mechanically sound"),
                        PerformanceCriteria(code: "3.2", description: "Complete the necessary identification of cables and conductors in accordance with regulatory requirements and organisational procedures"),
                        PerformanceCriteria(code: "3.3", description: "Dispose of unwanted material and equipment in accordance with site procedures and statutory requirements")
                       
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),
        
        Unit(
            code: "ELTP3-006",
            eltCode: "1605-ELTP3-006",
            reference: "ELTP3-006",
            title: "Inspecting, testing, commissioning and certifying electrotechnical systems",
            description: "Inspection, testing and commissioning of electrical installations",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation for Inspection and Testing",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Confirm scope of inspection and testing"),
                        PerformanceCriteria(code: "1.2", description: "Risk assess inspection and testing activities"),
                        PerformanceCriteria(code: "1.3", description: "Select appropriate test instruments"),
                        PerformanceCriteria(code: "1.4", description: "Verify test instruments are calibrated and functioning")
                    ]
                ),
                LearningOutcome(
                    number: "2", 
                    title: "Inspection Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Complete visual inspection according to requirements"),
                        PerformanceCriteria(code: "2.2", description: "Record inspection results accurately"),
                        PerformanceCriteria(code: "2.3", description: "Identify and report non-compliant items")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing Procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Perform tests in correct sequence:"),
                        PerformanceCriteria(code: "3.1a", description: "Continuity testing"),
                        PerformanceCriteria(code: "3.1b", description: "Insulation resistance testing"),
                        PerformanceCriteria(code: "3.1c", description: "Polarity testing"),
                        PerformanceCriteria(code: "3.1d", description: "Earth fault loop impedance testing"),
                        PerformanceCriteria(code: "3.1e", description: "RCD testing"),
                        PerformanceCriteria(code: "3.1f", description: "Phase sequence testing"),
                        PerformanceCriteria(code: "3.2", description: "Record test results accurately"),
                        PerformanceCriteria(code: "3.3", description: "Compare results with required values")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Commissioning and Certification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Complete commissioning of installation"),
                        PerformanceCriteria(code: "4.2", description: "Complete required certification documentation"),
                        PerformanceCriteria(code: "4.3", description: "Provide handover information to client")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3-007",
            eltCode: "1605-ELTP3-007",
            reference: "ELTP3-007",
            title: "Diagnosing and correcting electrical faults",
            description: "Fault diagnosis and correction in electrical installations",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation for Fault Diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Gather information about reported faults"),
                        PerformanceCriteria(code: "1.2", description: "Risk assess fault diagnosis activities"),
                        PerformanceCriteria(code: "1.3", description: "Select appropriate test instruments"),
                        PerformanceCriteria(code: "1.4", description: "Carry out safe isolation procedures")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Fault Diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Apply logical fault diagnosis procedures"),
                        PerformanceCriteria(code: "2.2", description: "Use appropriate testing methods"),
                        PerformanceCriteria(code: "2.3", description: "Interpret test results correctly"),
                        PerformanceCriteria(code: "2.4", description: "Identify cause of fault"),
                        PerformanceCriteria(code: "2.5", description: "Record findings accurately")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Fault Correction",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Select appropriate repair method"),
                        PerformanceCriteria(code: "3.2", description: "Obtain required replacement parts"),
                        PerformanceCriteria(code: "3.3", description: "Repair or replace faulty components"),
                        PerformanceCriteria(code: "3.4", description: "Test repaired circuit for correct operation"),
                        PerformanceCriteria(code: "3.5", description: "Restore supply safely"),
                        PerformanceCriteria(code: "3.6", description: "Complete required documentation")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Communication and Reporting",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Communicate effectively with relevant people:"),
                        PerformanceCriteria(code: "4.1a", description: "Clients/customers"),
                        PerformanceCriteria(code: "4.1b", description: "Other workers"),
                        PerformanceCriteria(code: "4.1c", description: "Supervisors"),
                        PerformanceCriteria(code: "4.2", description: "Provide clear explanation of:"),
                        PerformanceCriteria(code: "4.2a", description: "Fault found"),
                        PerformanceCriteria(code: "4.2b", description: "Work carried out"),
                        PerformanceCriteria(code: "4.2c", description: "Any further actions required")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),
        // Continue with ELTK3-002 through ELTK3-007
        // Then ELTP3-001 through ELTP3-007
        // Then QEOC3-001
        Unit(
            code: "QEOC3-001",
            eltCode: "1605-QEOC3-001",
            reference: "QEOC3-001",
            title: "Electrotechnical Occupational Competence",
            description: "Assessment of occupational competence in electrical installation",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "A",
                    title: "Composite Installation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "A1", description: "Safe Isolation and Risk Assessment")
                    ]
                ),
                LearningOutcome(
                    number: "B",
                    title: "Inspection and Testing",
                    performanceCriteria: [
                        PerformanceCriteria(code: "B1", description: "Complete inspection and testing of electrical installation")
                    ]
                ),
                LearningOutcome(
                    number: "C",
                    title: "Fault Diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "C1", description: "Diagnose and correct electrical faults")
                    ]
                ),
                LearningOutcome(
                    number: "D",
                    title: "Knowledge Assessment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "D1", description: "Complete online multiple choice examination")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

     ]
}

