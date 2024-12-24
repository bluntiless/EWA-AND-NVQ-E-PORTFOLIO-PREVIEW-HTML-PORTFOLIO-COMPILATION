import Foundation

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
            code: "NETP3-01",
            eltCode: "EWA01",
            reference: "NETP3-01",
            title: "Apply Health, Safety and Environmental Considerations",
            description: "Understanding and applying health and safety principles in electrical installation",
            unitType: .performance,
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
            code: "NETP3-03",
            eltCode: "EWA03",
            reference: "NETP3-03",
            title: "Organise and Oversee the Electrical Work Environment",
            description: "Organizing and overseeing electrical work activities",
            unitType: .performance,
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Be able to provide technical and functional information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Evaluate information requirements for:"),
                        PerformanceCriteria(code: "1.1a", description: "System operation"),
                        PerformanceCriteria(code: "1.1b", description: "Equipment functionality"),
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
                        PerformanceCriteria(code: "2.1", description: "Produce and revise risk assessments for:"),
                        PerformanceCriteria(code: "2.1a", description: "Own work activities"),
                        PerformanceCriteria(code: "2.1b", description: "Team activities"),
                        PerformanceCriteria(code: "2.1c", description: "Other operatives in area"),
                        PerformanceCriteria(code: "2.2", description: "Implement safety monitoring procedures"),
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
                        PerformanceCriteria(code: "3.1", description: "Coordinate with other workers/contractors"),
                        PerformanceCriteria(code: "3.2", description: "Resolve work-related issues"),
                        PerformanceCriteria(code: "3.3", description: "Monitor work progress"),
                        PerformanceCriteria(code: "3.4", description: "Report issues outside scope of responsibility")
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
            title: "Apply Design and Installation Practices and Procedures",
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
                        PerformanceCriteria(code: "05-1.1", description: "Evaluate and apply appropriate procedures to include:"),
                        PerformanceCriteria(code: "05-1.1a", description: "Selecting appropriate tools/equipment to enable termination and connection"),
                        PerformanceCriteria(code: "05-1.1b", description: "Adopting appropriate PPE"),
                        PerformanceCriteria(code: "05-1.1c", description: "Following a safe system of work (e.g. risk assessment, method statement, permit to work procedure)"),
                        PerformanceCriteria(code: "05-1.2", description: "Assess/confirm it is safe to complete termination & connection in terms of:"),
                        PerformanceCriteria(code: "05-1.2a", description: "Checking for presence of supply/carrying out safe isolation"),
                        PerformanceCriteria(code: "05-1.2b", description: "Mechanical soundness of the electrical equipment to be connected to"),
                        PerformanceCriteria(code: "05-1.2c", description: "Checking for unsafe situations")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Termination and Connection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "05-2.1", description: "Terminate/connect cables/conductors according to instructions/18th/specs:"),
                        PerformanceCriteria(code: "05-2.1a", description: "Single core cable (singles)"),
                        PerformanceCriteria(code: "05-2.1b", description: "Multicore insulated cable"),
                        PerformanceCriteria(code: "05-2.1c", description: "PVC / PVC flat profile cable (twin and earth)"),
                        PerformanceCriteria(code: "05-2.1d", description: "MICC cable"),
                        PerformanceCriteria(code: "05-2.1e", description: "Fire performance (such as FP 200 etc.)"),
                        PerformanceCriteria(code: "05-2.1f", description: "SWA cable"),
                        PerformanceCriteria(code: "05-2.1g", description: "GSWB galvanised steel wire braid"),
                        PerformanceCriteria(code: "05-2.1h", description: "Data cable"),
                        PerformanceCriteria(code: "05-2.2", description: "Connect equipment according to instructions/18th/drawings/specs:"),
                        PerformanceCriteria(code: "05-2.2a", description: "Isolators /switches"),
                        PerformanceCriteria(code: "05-2.2b", description: "Socket outlets"),
                        PerformanceCriteria(code: "05-2.2c", description: "Distribution-boards / consumer control units"),
                        PerformanceCriteria(code: "05-2.2d", description: "Luminaires"),
                        PerformanceCriteria(code: "05-2.2e", description: "Electric motors / motor control equipment"),
                        PerformanceCriteria(code: "05-2.2f", description: "Overcurrent protective devices"),
                        PerformanceCriteria(code: "05-2.2g", description: "Earthing terminals"),
                        PerformanceCriteria(code: "05-2.2h", description: "Control panels"),
                        PerformanceCriteria(code: "05-2.2i", description: "Data socket outlets or data connections"),
                        PerformanceCriteria(code: "05-2.2j", description: "Fire detection/alarm components"),
                        PerformanceCriteria(code: "05-2.2k", description: "Other appropriate equipment (such as: heating system components etc.)"),
                        PerformanceCriteria(code: "05-2.3", description: "Terminate and connect conductors, using appropriate methods:"),
                        PerformanceCriteria(code: "05-2.3a", description: "Screwing"),
                        PerformanceCriteria(code: "05-2.3b", description: "Crimping"),
                        PerformanceCriteria(code: "05-2.3c", description: "Soldering"),
                        PerformanceCriteria(code: "05-2.3d", description: "Non-screw compression"),
                        PerformanceCriteria(code: "05-2.3e", description: "Insulation displacement")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // NETP3-06
        Unit(
            code: "NETP3-06",
            eltCode: "EWA06",
            reference: "NETP3-06",
            title: "Inspect, Test and Commission Electrical Systems",
            description: "Inspection, testing and commissioning of electrical installations",
            unitType: .performance,
            creditValue: 3,
            glh: 26,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Be able to confirm safety of the system and equipment prior to completion of inspection, testing and commissioning",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures in accordance with regulatory requirements"),
                        PerformanceCriteria(code: "1.2", description: "Ensure the health and safety of themselves and others within the work location"),
                        PerformanceCriteria(code: "1.3", description: "Check the safety of electrical systems prior to inspection, testing and commissioning")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Be able to inspect electrical systems and equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Assess whether the safe system of work is appropriate to the work activity"),
                        PerformanceCriteria(code: "2.2", description: "Carry out visual inspection in accordance with BS 7671 and IET Guidance Note 3"),
                        PerformanceCriteria(code: "2.3", description: "Complete a schedule of inspections in accordance with BS 7671 and IET Guidance Note 3")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Be able to test and commission electrical systems and equipment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Select the correct test instruments and accessories for tests"),
                        PerformanceCriteria(code: "06-3.2", description: "Test according to installation specification & BS 7671 & instructions:"),
                        PerformanceCriteria(code: "06-3.2a", description: "Continuity"),
                        PerformanceCriteria(code: "06-3.2b", description: "Insulation resistance"),
                        PerformanceCriteria(code: "06-3.2c", description: "Polarity"),
                        PerformanceCriteria(code: "06-3.2d", description: "Earth fault loop impedance/earth electrode"),
                        PerformanceCriteria(code: "06-3.2e", description: "Prospective fault current"),
                        PerformanceCriteria(code: "06-3.2f", description: "RCD operation"),
                        PerformanceCriteria(code: "06-3.2g", description: "Functional testing"),
                        PerformanceCriteria(code: "06-3.3", description: "Analyse & Verify test results to relevant persons:"),
                        PerformanceCriteria(code: "06-3.3a", description: "Representatives of other services/colleagues"),
                        PerformanceCriteria(code: "06-3.3b", description: "Customers/clients"),
                        PerformanceCriteria(code: "06-3.4", description: "Complete in accordance with BS7671 and IET Guidance note 3:"),
                        PerformanceCriteria(code: "06-3.4a", description: "Electrical Installation Certificate (+ Schedule of Inspections and Schedule of Test Results)"),
                        PerformanceCriteria(code: "06-3.4b", description: "Minor Electrical Installation Works Certificate")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // ENTP3-07
        Unit(
            code: "ENTP3-07",
            eltCode: "EWA07",
            reference: "ENTP3-07",
            title: "Apply Fault Diagnosis and Rectification",
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
                        PerformanceCriteria(code: "07-2.6", description: "Suitable diagnostic test to identify fault:"),
                        PerformanceCriteria(code: "07-2.6a", description: "Loss of supply"),
                        PerformanceCriteria(code: "07-2.6b", description: "Overload"),
                        PerformanceCriteria(code: "07-2.6c", description: "Short-circuit"),
                        PerformanceCriteria(code: "07-2.6d", description: "Earth fault"),
                        PerformanceCriteria(code: "07-2.6e", description: "Incorrect phase rotation"),
                        PerformanceCriteria(code: "07-2.6f", description: "High resistance joints/loose terminations"),
                        PerformanceCriteria(code: "07-2.6g", description: "Component, accessory or equipment faults"),
                        PerformanceCriteria(code: "07-2.6h", description: "Open circuit"),
                        PerformanceCriteria(code: "07-2.6i", description: "Signal faults"),
                        PerformanceCriteria(code: "07-2.7", description: "Use appropriate methods for locating faults:"),
                        PerformanceCriteria(code: "07-2.7a", description: "Using a logical approach"),
                        PerformanceCriteria(code: "07-2.7b", description: "Using safe working practices"),
                        PerformanceCriteria(code: "07-2.7c", description: "Interpretation of test readings"),
                        PerformanceCriteria(code: "07-2.8", description: "Use appropriate instruments for fault diagnosis:"),
                        PerformanceCriteria(code: "07-2.8a", description: "Voltage indicator"),
                        PerformanceCriteria(code: "07-2.8b", description: "Low resistance ohm meter"),
                        PerformanceCriteria(code: "07-2.8c", description: "Insulation resistance tester"),
                        PerformanceCriteria(code: "07-2.8d", description: "EFLI and PFC tester"),
                        PerformanceCriteria(code: "07-2.8e", description: "RCD tester"),
                        PerformanceCriteria(code: "07-2.8f", description: "Ammeter"),
                        PerformanceCriteria(code: "07-2.8g", description: "Phase rotation tester"),
                        PerformanceCriteria(code: "07-2.8h", description: "Other appropriate instrument")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Carry out fault rectification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "07-3.1", description: "Assess repairs/removals/replacements/implications to:"),
                        PerformanceCriteria(code: "07-3.1a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "07-3.1b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.2", description: "Perform fault correction procedures correctly and safely"),
                        PerformanceCriteria(code: "07-3.3", description: "Assess & verify replacement components & associated equipment maintain:"),
                        PerformanceCriteria(code: "07-3.3a", description: "Ease of access for future maintenance"),
                        PerformanceCriteria(code: "07-3.3b", description: "Compliance with relevant regulations"),
                        PerformanceCriteria(code: "07-3.3c", description: "Compliance with manufacturer's instructions/procedures"),
                        PerformanceCriteria(code: "3.4", description: "Apply procedures to ensure electrical equipment is left safe"),
                        PerformanceCriteria(code: "3.5", description: "Establish and perform appropriate inspection and testing procedure"),
                        PerformanceCriteria(code: "07-3.6", description: "Record test results & other appropriate info regarding fault correction:"),
                        PerformanceCriteria(code: "07-3.6a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "07-3.6b", description: "Customers/clients"),
                        PerformanceCriteria(code: "07-3.6c", description: "Representatives of other services")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        )
    ]

    static let eal1605Units: [Unit] = [
        Unit(
            code: "QELF3/001",
            eltCode: "1605-001",
            reference: "1605-REF-001",
            title: "Understanding Electrical Installation Standards",
            description: "Core principles of electrical installation",
            unitType: .performance,
            creditValue: 12,
            glh: 6,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Installation Standards",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Select appropriate wiring systems"),
                        PerformanceCriteria(code: "1.2", description: "Install wiring systems including:"),
                        PerformanceCriteria(code: "1.2a", description: "PVC singles in conduit"),
                        PerformanceCriteria(code: "1.2b", description: "Twin and earth cables"),
                        PerformanceCriteria(code: "1.2c", description: "SWA cables"),
                        PerformanceCriteria(code: "1.2d", description: "Fire resistant cables"),
                        PerformanceCriteria(code: "1.3", description: "Install protective devices including:"),
                        PerformanceCriteria(code: "1.3a", description: "Main switches"),
                        PerformanceCriteria(code: "1.3b", description: "Circuit breakers"),
                        PerformanceCriteria(code: "1.3c", description: "RCDs"),
                        PerformanceCriteria(code: "1.3d", description: "RCBOs"),
                        PerformanceCriteria(code: "1.4", description: "Install earthing systems including:"),
                        PerformanceCriteria(code: "1.4a", description: "Main earthing terminal"),
                        PerformanceCriteria(code: "1.4b", description: "Circuit protective conductors"),
                        PerformanceCriteria(code: "1.4c", description: "Supplementary bonding")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Testing and Inspection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Carry out initial inspection"),
                        PerformanceCriteria(code: "2.2", description: "Test installations including:"),
                        PerformanceCriteria(code: "2.2a", description: "Continuity of protective conductors"),
                        PerformanceCriteria(code: "2.2b", description: "Insulation resistance"),
                        PerformanceCriteria(code: "2.2c", description: "Polarity"),
                        PerformanceCriteria(code: "2.2d", description: "Earth fault loop impedance"),
                        PerformanceCriteria(code: "2.2e", description: "RCD operation"),
                        PerformanceCriteria(code: "2.3", description: "Record test results"),
                        PerformanceCriteria(code: "2.4", description: "Complete certification documentation")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Fault Diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Identify common electrical faults"),
                        PerformanceCriteria(code: "3.2", description: "Use appropriate test equipment"),
                        PerformanceCriteria(code: "3.3", description: "Apply logical fault finding procedures"),
                        PerformanceCriteria(code: "3.4", description: "Repair faults in:"),
                        PerformanceCriteria(code: "3.4a", description: "Lighting circuits"),
                        PerformanceCriteria(code: "3.4b", description: "Power circuits"),
                        PerformanceCriteria(code: "3.4c", description: "Motors and controls")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        // QELF3/002
        Unit(
            code: "QELF3/002",
            eltCode: "1605-002",
            reference: "1605-REF-002",
            title: "Electrical Scientific Principles and Technologies",
            description: "Understanding electrical theory and applications",
            unitType: .knowledge,
            creditValue: 10,
            glh: 5,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Electrical Theory",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand fundamental electrical principles:"),
                        PerformanceCriteria(code: "1.1a", description: "Ohm's Law"),
                        PerformanceCriteria(code: "1.1b", description: "Power equations"),
                        PerformanceCriteria(code: "1.1c", description: "Energy calculations"),
                        PerformanceCriteria(code: "1.2", description: "Apply circuit principles:"),
                        PerformanceCriteria(code: "1.2a", description: "Series circuits"),
                        PerformanceCriteria(code: "1.2b", description: "Parallel circuits"),
                        PerformanceCriteria(code: "1.2c", description: "Series-parallel circuits")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Electrical Systems",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Understand three-phase systems:"),
                        PerformanceCriteria(code: "2.1a", description: "Star connection"),
                        PerformanceCriteria(code: "2.1b", description: "Delta connection"),
                        PerformanceCriteria(code: "2.1c", description: "Power calculations"),
                        PerformanceCriteria(code: "2.2", description: "Understand transformer principles:"),
                        PerformanceCriteria(code: "2.2a", description: "Turns ratio"),
                        PerformanceCriteria(code: "2.2b", description: "Voltage transformation"),
                        PerformanceCriteria(code: "2.2c", description: "Current transformation")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-001",
            eltCode: "1605-ELTK3-001",
            reference: "ELTK3-001",
            title: "Understanding health and safety legislation, practices and procedures",
            description: "Installing and maintaining electrotechnical systems and equipment",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Apply relevant health and safety legislation in the workplace",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify which workplace health and safety procedures are relevant to the working environment"),
                        PerformanceCriteria(code: "1.2", description: "Produce a risk assessment and method statement in accordance with organisational procedures"),
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
                        PerformanceCriteria(code: "2.2", description: "Assess work environment, revise work practices of hazards:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials"),
                        PerformanceCriteria(code: "2.2b", description: "Equipment"),
                        PerformanceCriteria(code: "2.2c", description: "Tools")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Apply methods and procedures for safe work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.2", description: "Storage of tools, plant and equipment as stipulated in:"),
                        PerformanceCriteria(code: "3.2a", description: "Workplace policies (company and site)"),
                        PerformanceCriteria(code: "3.2b", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "3.2c", description: "Supplier information")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Apply procedures for health and safety incidents",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Correct procedure to follow in event of injury to themselves or others:"),
                        PerformanceCriteria(code: "4.1a", description: "Reporting of incidents"),
                        PerformanceCriteria(code: "4.1b", description: "Notification of emergency services"),
                        PerformanceCriteria(code: "4.1c", description: "Applying basic first aid procedures")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-002",
            eltCode: "1605-ELTK3-002",
            reference: "ELTK3-002",
            title: "Understanding environmental legislation, working practices and principles",
            description: "Environmental technology systems and legislation",
            unitType: .knowledge,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Apply environmental legislation and working practices",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Demonstrate workplace procedures for safe handling, storage and disposal of hazardous materials:"),
                        PerformanceCriteria(code: "1.1a", description: "Environmental Protection Act"),
                        PerformanceCriteria(code: "1.1b", description: "The Hazardous Waste Regulations"),
                        PerformanceCriteria(code: "1.1c", description: "Pollution Prevention and Control Act"),
                        PerformanceCriteria(code: "1.1d", description: "Control of Pollution Act"),
                        PerformanceCriteria(code: "1.1e", description: "The Control of Noise at Work Regulations"),
                        PerformanceCriteria(code: "1.1f", description: "Packaging (Essential Requirements) Regulations"),
                        PerformanceCriteria(code: "1.1g", description: "The Waste Electrical and Electronic Equipment Regulations"),
                        PerformanceCriteria(code: "1.1h", description: "Environment Act")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Supply information on environmental technology systems",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Operational requirements & benefits of environmental technology systems:"),
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
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-003",
            eltCode: "1605-ELTK3-003",
            reference: "ELTK3-003",
            title: "Understanding the practices and procedures for overseeing and organising the work environment",
            description: "Electrical installation work environment organization",
            unitType: .knowledge,
            creditValue: 5,
            glh: 45,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Provide relevant people with technical and functional information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify the relevant people that need to be supplied with technical and functional information"),
                        PerformanceCriteria(code: "1.2", description: "Identify any additional information that may also be required such as:"),
                        PerformanceCriteria(code: "1.2a", description: "Health and safety information"),
                        PerformanceCriteria(code: "1.2b", description: "The isolation procedures for products/equipment in case of emergencies"),
                        PerformanceCriteria(code: "1.2c", description: "The appropriate person's address or contact details for further advice or help"),
                        PerformanceCriteria(code: "1.3", description: "Liaise with the relevant people to determine information they require"),
                        PerformanceCriteria(code: "1.4", description: "Identify appropriate technical and functional information"),
                        PerformanceCriteria(code: "1.5", description: "Provide information in a timely, courteous and professional manner")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Organise and oversee work activities and operations",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Organise operatives by allocating duties and responsibilities"),
                        PerformanceCriteria(code: "4.2", description: "Monitor the work of operatives to ensure it is in accordance with:"),
                        PerformanceCriteria(code: "4.2a", description: "The programme of work"),
                        PerformanceCriteria(code: "4.2b", description: "Cost effectiveness"),
                        PerformanceCriteria(code: "4.2c", description: "Industry working practices"),
                        PerformanceCriteria(code: "4.2d", description: "Health and safety requirements"),
                        PerformanceCriteria(code: "4.3", description: "Apply correct procedures when non-compliance is identified")
                    ]
                ),
                LearningOutcome(
                    number: "5",
                    title: "Organise a programme for working",
                    performanceCriteria: [
                        PerformanceCriteria(code: "5.1", description: "Produce a programme of work from work specification, including:"),
                        PerformanceCriteria(code: "5.1a", description: "Liaison with other trades where necessary"),
                        PerformanceCriteria(code: "5.1b", description: "Estimation of the amount of time required for completion"),
                        PerformanceCriteria(code: "5.2", description: "Communicate with others clearly and concisely"),
                        PerformanceCriteria(code: "5.3", description: "Identify situations requiring liaison with other relevant parties")
                    ]
                ),
                LearningOutcome(
                    number: "6",
                    title: "Organise resource requirements",
                    performanceCriteria: [
                        PerformanceCriteria(code: "6.1", description: "Procedures for organising provision of resources:"),
                        PerformanceCriteria(code: "6.1a", description: "Materials"),
                        PerformanceCriteria(code: "6.1b", description: "Measuring and test instruments"),
                        PerformanceCriteria(code: "6.1c", description: "Equipment"),
                        PerformanceCriteria(code: "6.1d", description: "Labour"),
                        PerformanceCriteria(code: "6.1e", description: "Tools"),
                        PerformanceCriteria(code: "6.1f", description: "Components"),
                        PerformanceCriteria(code: "6.1g", description: "Plant"),
                        PerformanceCriteria(code: "6.2", description: "Procedures for confirming materials available are:"),
                        PerformanceCriteria(code: "6.2a", description: "The right type"),
                        PerformanceCriteria(code: "6.2b", description: "Fit for purpose"),
                        PerformanceCriteria(code: "6.2c", description: "Suitable for work to be completed cost efficiently"),
                        PerformanceCriteria(code: "6.2d", description: "In the correct quantity")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-004",
            eltCode: "1605-ELTK3-004",
            reference: "ELTK3-004",
            title: "Understanding the practices & procedures for the preparation & installation of wiring systems",
            description: "Installation of wiring systems and electrotechnical equipment",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Preparation for installation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.3", description: "Prep work for installation of electrical systems, enclosures and equipment:"),
                        PerformanceCriteria(code: "1.3a", description: "Interpretation of installation specifications to produce material and equipment requisites"),
                        PerformanceCriteria(code: "1.3b", description: "Identification and selection of material, equipment and components which are compatible with the installation specification"),
                        PerformanceCriteria(code: "1.3c", description: "Identification of suitable methods, procedures and practices"),
                        PerformanceCriteria(code: "1.3d", description: "Confirmation of site readiness for installation work to begin"),
                        PerformanceCriteria(code: "1.3e", description: "Confirmation of secure site storage facilities for tools, equipment, materials and components"),
                        PerformanceCriteria(code: "1.3f", description: "Equipment, materials and components in accordance with regulatory requirements"),
                        PerformanceCriteria(code: "1.3g", description: "Completion of a risk assessment")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Documentation and information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Use information & documentation that current & relevant to work required:"),
                        PerformanceCriteria(code: "2.1a", description: "Installation specifications"),
                        PerformanceCriteria(code: "2.1b", description: "Work schedules"),
                        PerformanceCriteria(code: "2.1c", description: "Work programmes"),
                        PerformanceCriteria(code: "2.1d", description: "Method statements"),
                        PerformanceCriteria(code: "2.1e", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "2.1f", description: "Regulatory documents (including current version of BS 7671 and relevant Guidance Notes)"),
                        PerformanceCriteria(code: "2.2", description: "Confirm materials, equipment is the correct quantity & free from damage:"),
                        PerformanceCriteria(code: "2.2a", description: "Materials schedules"),
                        PerformanceCriteria(code: "2.2b", description: "Plant and equipment schedules"),
                        PerformanceCriteria(code: "2.2c", description: "Operating instructions"),
                        PerformanceCriteria(code: "2.2d", description: "Tools and instruments")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Record keeping and authorization",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Use appropriate procedures to record:"),
                        PerformanceCriteria(code: "3.1a", description: "Contract variations"),
                        PerformanceCriteria(code: "3.1b", description: "Site instructions"),
                        PerformanceCriteria(code: "3.1c", description: "Site events/diary"),
                        PerformanceCriteria(code: "3.2", description: "Authorization been obtained from relevant person(s) prior to work:"),
                        PerformanceCriteria(code: "3.2a", description: "Other workers"),
                        PerformanceCriteria(code: "3.2b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.2c", description: "Public (If appropriate)")
                    ]
                ),
                LearningOutcome(
                    number: "6",
                    title: "Installation procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "6.1", description: "Plan programme of fitting/fixing of wiring systems, enclosures & equipment:"),
                        PerformanceCriteria(code: "6.1a", description: "A safe system of work"),
                        PerformanceCriteria(code: "6.1b", description: "Co-ordination with other site services"),
                        PerformanceCriteria(code: "6.1c", description: "Installation specification"),
                        PerformanceCriteria(code: "6.1d", description: "Manufacturers' instructions"),
                        PerformanceCriteria(code: "6.1e", description: "Relevant regulations (e.g. BS 7671, Building- Regulations)"),
                        PerformanceCriteria(code: "6.2", description: "Install according to IET wiring regs, specification agreed plan of work:"),
                        PerformanceCriteria(code: "6.2a", description: "PVC/PVC flat profile cable (Multicore)"),
                        PerformanceCriteria(code: "6.2b", description: "SWA (Steel Wire Armoured)"),
                        PerformanceCriteria(code: "6.2c", description: "Single and multicore thermoplastic"),
                        PerformanceCriteria(code: "6.2d", description: "Fire resistant cabling (FP 200, MICC etc.)"),
                        PerformanceCriteria(code: "6.3", description: "Install according to IET wiring regs, install spec, agreed plan of work:"),
                        PerformanceCriteria(code: "6.3a", description: "PVC Conduit"),
                        PerformanceCriteria(code: "6.3b", description: "Metal Conduit"),
                        PerformanceCriteria(code: "6.3c", description: "PVC Trunking"),
                        PerformanceCriteria(code: "6.3d", description: "Metal Trunking"),
                        PerformanceCriteria(code: "6.3e", description: "Cable Tray"),
                        PerformanceCriteria(code: "6.5", description: "Install according to IET wiring regs, install spec, agreed plan of work:"),
                        PerformanceCriteria(code: "6.5a", description: "Isolators and switches"),
                        PerformanceCriteria(code: "6.5b", description: "Socket-outlets"),
                        PerformanceCriteria(code: "6.5c", description: "Distribution-boards"),
                        PerformanceCriteria(code: "6.5d", description: "Consumer units"),
                        PerformanceCriteria(code: "6.5e", description: "Control equipment"),
                        PerformanceCriteria(code: "6.5f", description: "Luminaires"),
                        PerformanceCriteria(code: "6.5g", description: "Auxiliary equipment (e.g. heating/water system components)"),
                        PerformanceCriteria(code: "6.5h", description: "Earthing fault and overcurrent protective devices"),
                        PerformanceCriteria(code: "6.5i", description: "Data socket outlets")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTK3-004A",
            eltCode: "1605-ELTK3-004A",
            reference: "ELTK3-004A",
            title: "Understanding the principles of planning and selection for the installation of electrotechnical equipment",
            description: "Planning and selection for electrical installations",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Planning and Selection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Understand installation planning requirements"),
                        PerformanceCriteria(code: "1.2", description: "Select appropriate equipment and systems"),
                        PerformanceCriteria(code: "1.3", description: "Calculate installation requirements")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        ),

        Unit(
            code: "ELTP3/001",
            eltCode: "1605-ELTP3-001",
            reference: "ELTP3/001",
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
                        PerformanceCriteria(code: "3.2b", description: "Supplier information"),
                        PerformanceCriteria(code: "3.2c", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "3.3", description: "Comply with hazard warning and mandatory instruction notices"),
                        PerformanceCriteria(code: "3.4", description: "Apply procedures to ensure safety through correct use of guards"),
                        PerformanceCriteria(code: "3.5", description: "Use access equipment correctly")
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
            code: "ELTP3/002",
            eltCode: "1605-ELTP3-002",
            reference: "ELTP3/002",
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
                    title: "Apply Environmental Practices",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Apply environmental protection measures"),
                        PerformanceCriteria(code: "1.2", description: "Implement waste management procedures"),
                        PerformanceCriteria(code: "1.3", description: "Follow environmental legislation requirements")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3/003",
            eltCode: "1605-ELTP3-003",
            reference: "ELTP3/003",
            title: "Overseeing and organising the work environment",
            description: "Electrical installation work environment management",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Provide technical and functional information",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Identify relevant people that need technical/functional information"),
                        PerformanceCriteria(code: "1.2", description: "Identify additional information required:"),
                        PerformanceCriteria(code: "1.2a", description: "Health and safety information"),
                        PerformanceCriteria(code: "1.2b", description: "Isolation procedures for products/equipment in emergencies"),
                        PerformanceCriteria(code: "1.2c", description: "Contact details for further advice/help"),
                        PerformanceCriteria(code: "1.3", description: "Liaise with relevant people to determine information needs"),
                        PerformanceCriteria(code: "1.4", description: "Identify appropriate technical and functional information"),
                        PerformanceCriteria(code: "1.5", description: "Provide information professionally and according to procedures")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Oversee health and safety",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Produce risk assessments and method statements for:"),
                        PerformanceCriteria(code: "2.1a", description: "Own work activities"),
                        PerformanceCriteria(code: "2.1b", description: "Team activities"),
                        PerformanceCriteria(code: "2.1c", description: "Other operatives in work area"),
                        PerformanceCriteria(code: "2.2", description: "Follow procedures to confirm work complies with:"),
                        PerformanceCriteria(code: "2.2a", description: "Health and safety legislation"),
                        PerformanceCriteria(code: "2.2b", description: "Industry standards"),
                        PerformanceCriteria(code: "2.2c", description: "Company procedures")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Coordinate work activities",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Follow procedures for effective coordination with other workers"),
                        PerformanceCriteria(code: "3.2", description: "Use clear and appropriate communication methods"),
                        PerformanceCriteria(code: "3.3", description: "Resolve issues within scope of job role"),
                        PerformanceCriteria(code: "3.4", description: "Report issues outside scope to relevant person")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Organize and monitor work",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Organize operatives by allocating duties based on competence"),
                        PerformanceCriteria(code: "4.2", description: "Monitor work to ensure compliance with:"),
                        PerformanceCriteria(code: "4.2a", description: "Programme of work"),
                        PerformanceCriteria(code: "4.2b", description: "Cost effectiveness"),
                        PerformanceCriteria(code: "4.2c", description: "Industry working practices"),
                        PerformanceCriteria(code: "4.2d", description: "Health and safety requirements"),
                        PerformanceCriteria(code: "4.3", description: "Apply procedures when non-compliance identified")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "AM2",
            eltCode: "1605-AM2",
            reference: "AM2",
            title: "Electrotechnical Occupation Competence",
            description: "Assessment of occupational competence",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Practical Assessment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Complete installation to required standards"),
                        PerformanceCriteria(code: "1.2", description: "Test and commission installations"),
                        PerformanceCriteria(code: "1.3", description: "Diagnose and rectify faults")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Theory Assessment",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Demonstrate knowledge of electrical theory"),
                        PerformanceCriteria(code: "2.2", description: "Apply safe working practices"),
                        PerformanceCriteria(code: "2.3", description: "Complete required documentation")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3/004",
            eltCode: "1605-ELTP3-004",
            reference: "ELTP3/004",
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
                    title: "Preparation and Planning",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Confirm site readiness for installation work to begin"),
                        PerformanceCriteria(code: "1.2", description: "Confirm secure site storage facilities for tools, equipment, materials"),
                        PerformanceCriteria(code: "1.3", description: "Select materials in accordance with the installation specification"),
                        PerformanceCriteria(code: "1.4", description: "Report any pre-work damage/defects to relevant person(s)"),
                        PerformanceCriteria(code: "1.5", description: "Confirm authorization for installation work to start")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Installation Methods",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Install wiring systems according to BS7671/installation specification:"),
                        PerformanceCriteria(code: "2.1a", description: "PVC/PVC flat profile cable"),
                        PerformanceCriteria(code: "2.1b", description: "Steel wire armoured cables"),
                        PerformanceCriteria(code: "2.1c", description: "Fire resistant cables"),
                        PerformanceCriteria(code: "2.1d", description: "MICC cables"),
                        PerformanceCriteria(code: "2.2", description: "Install containment systems according to BS7671/specification:"),
                        PerformanceCriteria(code: "2.2a", description: "Metal conduit"),
                        PerformanceCriteria(code: "2.2b", description: "Plastic conduit"),
                        PerformanceCriteria(code: "2.2c", description: "Metal trunking"),
                        PerformanceCriteria(code: "2.2d", description: "Plastic trunking"),
                        PerformanceCriteria(code: "2.2e", description: "Cable tray systems")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Installation Standards",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Install equipment according to manufacturer instructions/BS7671:"),
                        PerformanceCriteria(code: "3.1a", description: "Isolators and switches"),
                        PerformanceCriteria(code: "3.1b", description: "Socket-outlets"),
                        PerformanceCriteria(code: "3.1c", description: "Distribution boards"),
                        PerformanceCriteria(code: "3.1d", description: "Consumer units"),
                        PerformanceCriteria(code: "3.1e", description: "Protective devices"),
                        PerformanceCriteria(code: "3.1f", description: "Luminaires"),
                        PerformanceCriteria(code: "3.1g", description: "Control equipment"),
                        PerformanceCriteria(code: "3.2", description: "Check installations are complete and comply with specifications")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3/005",
            eltCode: "1605-ELTP3-005",
            reference: "ELTP3/005",
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

        Unit(
            code: "ELTP3/006",
            eltCode: "1605-ELTP3-006",
            reference: "ELTP3/006",
            title: "Inspecting, testing, commissioning and certifying electrotechnical systems",
            description: "Testing and certification of electrical installations",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Safety Confirmation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures in accordance with regulatory requirements"),
                        PerformanceCriteria(code: "1.2", description: "Ensure health and safety of self and others within work location"),
                        PerformanceCriteria(code: "1.3", description: "Check safety of electrical systems prior to inspection and testing")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Visual Inspection",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Carry out visual inspection according to IET Wiring Regulations:"),
                        PerformanceCriteria(code: "2.1a", description: "Confirming safety of the installation"),
                        PerformanceCriteria(code: "2.1b", description: "Checking compliance with specifications"),
                        PerformanceCriteria(code: "2.1c", description: "Identifying visible defects"),
                        PerformanceCriteria(code: "2.2", description: "Complete inspection schedule recording all observations")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Select appropriate test instruments and verify calibration for:"),
                        PerformanceCriteria(code: "3.1a", description: "Continuity testing"),
                        PerformanceCriteria(code: "3.1b", description: "Insulation resistance testing"),
                        PerformanceCriteria(code: "3.1c", description: "Earth fault loop impedance testing"),
                        PerformanceCriteria(code: "3.1d", description: "RCD testing"),
                        PerformanceCriteria(code: "3.1e", description: "Prospective fault current testing"),
                        PerformanceCriteria(code: "3.2", description: "Carry out tests in accordance with BS7671:"),
                        PerformanceCriteria(code: "3.2a", description: "Continuity of protective conductors"),
                        PerformanceCriteria(code: "3.2b", description: "Continuity of ring final circuit conductors"),
                        PerformanceCriteria(code: "3.2c", description: "Insulation resistance"),
                        PerformanceCriteria(code: "3.2d", description: "Polarity"),
                        PerformanceCriteria(code: "3.2e", description: "Earth fault loop impedance"),
                        PerformanceCriteria(code: "3.2f", description: "RCD operation"),
                        PerformanceCriteria(code: "3.2g", description: "Phase sequence"),
                        PerformanceCriteria(code: "3.2h", description: "Functional testing")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Certification",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Complete certification documentation according to BS7671:"),
                        PerformanceCriteria(code: "4.1a", description: "Electrical Installation Certificate"),
                        PerformanceCriteria(code: "4.1b", description: "Schedule of Inspections"),
                        PerformanceCriteria(code: "4.1c", description: "Schedule of Test Results"),
                        PerformanceCriteria(code: "4.1d", description: "Minor Electrical Installation Works Certificate")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTP3/007",
            eltCode: "1605-ELTP3-007",
            reference: "ELTP3/007",
            title: "Diagnosing and correcting electrical faults",
            description: "Fault finding in electrical systems",
            unitType: .performance,
            creditValue: 4,
            glh: 35,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "1",
                    title: "Safety and Preparation",
                    performanceCriteria: [
                        PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures before fault diagnosis"),
                        PerformanceCriteria(code: "1.2", description: "Ensure health and safety of self and others in work location"),
                        PerformanceCriteria(code: "1.3", description: "Select appropriate tools and test equipment for fault diagnosis"),
                        PerformanceCriteria(code: "1.4", description: "Check the safety of electrical systems prior to the commencement of diagnosing and correcting electrical faults")
                    ]
                ),
                LearningOutcome(
                    number: "2",
                    title: "Fault Diagnosis",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.1", description: "Collect and analyze information about the fault:"),
                        PerformanceCriteria(code: "2.1a", description: "Installation specifications"),
                        PerformanceCriteria(code: "2.1b", description: "Circuit diagrams"),
                        PerformanceCriteria(code: "2.1c", description: "Maintenance records"),
                        PerformanceCriteria(code: "2.1d", description: "Fault history"),
                        PerformanceCriteria(code: "2.2", description: "Use appropriate diagnostic methods and techniques:"),
                        PerformanceCriteria(code: "2.2a", description: "Visual inspection"),
                        PerformanceCriteria(code: "2.2b", description: "Testing"),
                        PerformanceCriteria(code: "2.2c", description: "Measurement"),
                        PerformanceCriteria(code: "2.3", description: "Report info to relevant people about potential disruption as a consequence:"),
                        PerformanceCriteria(code: "2.3a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "2.3b", description: "Customers/clients"),
                        PerformanceCriteria(code: "2.5", description: "Diagnostic tests on installed electrotechnical systems:"),
                        PerformanceCriteria(code: "2.5a", description: "Loss of supply"),
                        PerformanceCriteria(code: "2.5b", description: "Overload"),
                        PerformanceCriteria(code: "2.5c", description: "Short-circuit and earth fault"),
                        PerformanceCriteria(code: "2.5d", description: "Transient voltage"),
                        PerformanceCriteria(code: "2.5e", description: "Loss of phase/line"),
                        PerformanceCriteria(code: "2.5f", description: "Incorrect phase rotation"),
                        PerformanceCriteria(code: "2.5g", description: "High resistance joints"),
                        PerformanceCriteria(code: "2.5h", description: "Component, accessory or equipment faults"),
                        PerformanceCriteria(code: "2.6", description: "Appropriate methods for locating faults on electrical systems equipment:"),
                        PerformanceCriteria(code: "2.6a", description: "Interpretation of data"),
                        PerformanceCriteria(code: "2.6b", description: "Safe working practices"),
                        PerformanceCriteria(code: "2.6c", description: "Procedures and sequences – logical approach"),
                        PerformanceCriteria(code: "2.7", description: "Appropriate tools & instruments correctly to complete fault diagnosis work:"),
                        PerformanceCriteria(code: "2.7a", description: "Voltage indicator"),
                        PerformanceCriteria(code: "2.7b", description: "Low resistance ohm meter"),
                        PerformanceCriteria(code: "2.7c", description: "Insulation resistance testers"),
                        PerformanceCriteria(code: "2.7d", description: "EFLI and PFC tester"),
                        PerformanceCriteria(code: "2.7e", description: "RCD tester"),
                        PerformanceCriteria(code: "2.7f", description: "Tong tester/clamp on ammeter"),
                        PerformanceCriteria(code: "2.7g", description: "Phase sequence tester")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Fault Correction",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Confirm appropriate repairs, removals & replacements their implications to:"),
                        PerformanceCriteria(code: "3.1a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "3.1b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.3", description: "Removal & replacement of components:"),
                        PerformanceCriteria(code: "3.3a", description: "The ease of access for future maintenance"),
                        PerformanceCriteria(code: "3.3b", description: "It is in accordance with relevant regulations"),
                        PerformanceCriteria(code: "3.3c", description: "It is in accordance with manufacturers instructions"),
                        PerformanceCriteria(code: "3.3d", description: "It is in accordance with organisational procedures"),
                        PerformanceCriteria(code: "3.6", description: "Record results regarding fault correction work to:"),
                        PerformanceCriteria(code: "3.6a", description: "Other workers/colleagues"),
                        PerformanceCriteria(code: "3.6b", description: "Customers/clients"),
                        PerformanceCriteria(code: "3.6c", description: "Representatives of other services")
                    ]
                )
            ],
            allowedAssessmentMethods: [.directObservation, .productEvidence]
        ),

        Unit(
            code: "ELTK3-006",
            eltCode: "1605-ELTK3-006",
            reference: "ELTK3-006",
            title: "Understanding the principles, practices and legislation for inspection, testing and commissioning",
            description: "Testing and certification procedures",
            unitType: .knowledge,
            creditValue: 6,
            glh: 52,
            startDate: DateHelper.getStandardDateRange().start,
            endDate: DateHelper.getStandardDateRange().end,
            learningOutcomes: [
                LearningOutcome(
                    number: "2",
                    title: "Visual inspection procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "2.2", description: "Visual inspection according to install spec/IET Regs & guidance note 3:"),
                        PerformanceCriteria(code: "2.2a", description: "Isolation"),
                        PerformanceCriteria(code: "2.2b", description: "Presence of means of earthing"),
                        PerformanceCriteria(code: "2.2c", description: "The installation methods of wiring systems and equipment"),
                        PerformanceCriteria(code: "2.2d", description: "The selection of conductors and cables"),
                        PerformanceCriteria(code: "2.2e", description: "The selection of protective and isolation devices"),
                        PerformanceCriteria(code: "2.2f", description: "Presence of protective conductors and bonding"),
                        PerformanceCriteria(code: "2.2g", description: "Type and rating of overcurrent protective devices"),
                        PerformanceCriteria(code: "2.2h", description: "Routing and identification/labelling of conductors, cables and flexible cords")
                    ]
                ),
                LearningOutcome(
                    number: "3",
                    title: "Testing procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "3.1", description: "Select the test instruments and their accessories for the following tests:"),
                        PerformanceCriteria(code: "3.1a", description: "Continuity"),
                        PerformanceCriteria(code: "3.1b", description: "Insulation resistance"),
                        PerformanceCriteria(code: "3.1c", description: "Polarity"),
                        PerformanceCriteria(code: "3.1d", description: "Earth fault loop impedance"),
                        PerformanceCriteria(code: "3.1e", description: "Prospective fault current"),
                        PerformanceCriteria(code: "3.1f", description: "RCD operation"),
                        PerformanceCriteria(code: "3.1g", description: "Phase sequence"),
                        PerformanceCriteria(code: "3.1h", description: "Functional testing")
                    ]
                ),
                LearningOutcome(
                    number: "4",
                    title: "Commissioning procedures",
                    performanceCriteria: [
                        PerformanceCriteria(code: "4.1", description: "Clarify the commissioning procedures with relevant persons on site:"),
                        PerformanceCriteria(code: "4.1a", description: "Representatives of other services/colleagues"),
                        PerformanceCriteria(code: "4.1b", description: "Customers/clients"),
                        PerformanceCriteria(code: "4.2", description: "Commission circuits/equipment/components confirm functionality:"),
                        PerformanceCriteria(code: "4.2a", description: "The installation specification"),
                        PerformanceCriteria(code: "4.2b", description: "IET Wiring Regulations"),
                        PerformanceCriteria(code: "4.2c", description: "Manufacturer's instructions"),
                        PerformanceCriteria(code: "4.2d", description: "Maintenance schedules"),
                        PerformanceCriteria(code: "4.2e", description: "Health and safety requirements")
                    ]
                )
            ],
            allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
        )
    ]
}
