import Foundation
import Combine
// Use the Unit class from Unit.swift

let cityAndGuilds2357Units: [Unit] = [
    // Unit 311
    Unit(
        code: "311",
        eltCode: "ELTP01",
        reference: "311",
        title: "Understanding Health and Safety Legislation and Working Practices",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .CityAndGuilds,
        creditValue: 12,
        glh: 100,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know health and safety legislation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Identify relevant health and safety legislation"),
                    PerformanceCriteria(code: "1.2", description: "Explain the purpose of legislation in maintaining safety"),
                    PerformanceCriteria(code: "1.3", description: "State employer and employee responsibilities"),
                    PerformanceCriteria(code: "1.4", description: "Explain how legislation is enforced")
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know how to assess workplace risks",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Identify common workplace hazards"),
                    PerformanceCriteria(code: "2.2", description: "Explain methods of risk assessment"),
                    PerformanceCriteria(code: "2.3", description: "Describe ways to control workplace risks"),
                    PerformanceCriteria(code: "2.4", description: "State procedures for reporting hazards")
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know safe working practices",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Describe safe manual handling techniques"),
                    PerformanceCriteria(code: "3.2", description: "Explain safe use of work equipment"),
                    PerformanceCriteria(code: "3.3", description: "State requirements for PPE"),
                    PerformanceCriteria(code: "3.4", description: "Describe emergency procedures")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 312 - Performance Unit
    Unit(
        code: "2357-312",
        eltCode: "ELTP02",
        reference: "312",
        title: "Installing and Testing Electrical Systems",
        description: "Installation and testing of electrical systems and equipment",
        unitType: .CityAndGuilds,
        creditValue: 12,
        glh: 100,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Installation Planning",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Plan installation work using specifications"),
                    PerformanceCriteria(code: "1.2", description: "Select appropriate tools and equipment"),
                    PerformanceCriteria(code: "1.3", description: "Risk assess installation activities")
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Installation Methods",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Install wiring systems to specifications"),
                    PerformanceCriteria(code: "2.2", description: "Install electrical equipment"),
                    PerformanceCriteria(code: "2.3", description: "Apply safe isolation procedures")
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Testing and Commissioning",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Complete installation testing"),
                    PerformanceCriteria(code: "3.2", description: "Commission installed systems"),
                    PerformanceCriteria(code: "3.3", description: "Complete documentation")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence]
    ),

    // Unit 313 - Performance Unit
    Unit(
        code: "2357-313",
        eltCode: "ELTP03",
        reference: "313",
        title: "Fault Diagnosis and Rectification",
        description: "Diagnosing and correcting electrical faults",
        unitType: .CityAndGuilds,
        creditValue: 12,
        glh: 100,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Fault Diagnosis",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Gather fault information"),
                    PerformanceCriteria(code: "1.2", description: "Use diagnostic techniques"),
                    PerformanceCriteria(code: "1.3", description: "Identify fault location")
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Fault Rectification",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Plan repair work"),
                    PerformanceCriteria(code: "2.2", description: "Replace faulty components"),
                    PerformanceCriteria(code: "2.3", description: "Test repaired circuits")
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Record fault details"),
                    PerformanceCriteria(code: "3.2", description: "Document repair work"),
                    PerformanceCriteria(code: "3.3", description: "Update maintenance records")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence]
    ),

    // Unit 315
    Unit(
        code: "315",
        eltCode: "ELTP04",
        reference: "315",
        title: "Planning, preparing and installing wiring systems and associated equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .performance,
        creditValue: 12,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know how to plan and prepare",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Ensure the health and safety of themselves and others within the work location"),
                    PerformanceCriteria(code: "1.2", description: "Identify and use suitable personal protective equipment throughout the completion of work activities"),
                    PerformanceCriteria(code: "1.3", description: "Complete preparatory work for the installation of electrical systems, enclosures and associated equipment"),
                ]
            ),
            LearningOutcome(
                number: "1.3",
                title: "Know preparatory work",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.3a", description: "• Interpretation of installation specifications to produce material and equipment requisites"),
                    PerformanceCriteria(code: "1.3b", description: "• Identification and selection of material, equipment and components which are compatible with the installation specification"),
                    PerformanceCriteria(code: "1.3c", description: "• Identification of suitable methods, procedures and practices"),
                    PerformanceCriteria(code: "1.3d", description: "• Confirmation of site readiness for installation work to begin"),
                    PerformanceCriteria(code: "1.3e", description: "• Confirmation of secure site storage facilities for tools, equipment, materials and components"),
                    PerformanceCriteria(code: "1.3f", description: "• Confirmation that safe isolation has been carried out (if appropriate) in accordance with regulatory requirements"),
                    PerformanceCriteria(code: "1.3g", description: "• Completion of a risk assessment"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know how to use information and documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Use information and documentation that is current and relevant to the work required"),
                    PerformanceCriteria(code: "2.2", description: "Use documentation to confirm that materials and equipment is of the correct quantity and is free from damage"),
                ]
            ),
            LearningOutcome(
                number: "2.1",
                title: "Know information and documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1a", description: "• Installation specifications"),
                    PerformanceCriteria(code: "2.1b", description: "• Work schedules"),
                    PerformanceCriteria(code: "2.1c", description: "• Work programmes"),
                    PerformanceCriteria(code: "2.1d", description: "• Regulatory documents (including current version of the iee wiring regulations and relevant guidance notes)"),
                    PerformanceCriteria(code: "2.1e", description: "• Method statements"),
                    PerformanceCriteria(code: "2.1f", description: "• Manufacturer's instructions"),
                ]
            ),
            LearningOutcome(
                number: "2.2",
                title: "Know documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.2a", description: "• Materials schedules"),
                    PerformanceCriteria(code: "2.2b", description: "• Plant and equipment schedules"),
                    PerformanceCriteria(code: "2.2c", description: "• Operating instructions"),
                    PerformanceCriteria(code: "2.2d", description: "• Tools and instruments"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know how to record",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Use appropriate procedures to record:"),
                    PerformanceCriteria(code: "3.1a", description: "• Contract variations"),
                    PerformanceCriteria(code: "3.1b", description: "• Site instructions"),
                    PerformanceCriteria(code: "3.1c", description: "• Site events/diary"),
                ]
            ),
            LearningOutcome(
                number: "3.1",
                title: "Know recording",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1a", description: "• Contract variations"),
                    PerformanceCriteria(code: "3.1b", description: "• Site instructions"),
                    PerformanceCriteria(code: "3.1c", description: "• Site events/diary"),
                ]
            ),
            LearningOutcome(
                number: "3.2",
                title: "Know how to authorise",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.2", description: "Demonstrate that authorisation has been obtained from the relevant person(s) prior to commencement of the work"),
                    PerformanceCriteria(code: "3.3", description: "Produce a record of any pre work damage or defects to existing equipment or building features, and report to the relevant person (customer; client; site manager; line manager)"),
                ]
            ),
            LearningOutcome(
                number: "3.2a",
                title: "Know authorisation",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.2a", description: "• Other workers"),
                    PerformanceCriteria(code: "3.2b", description: "• Customers/clients"),
                    PerformanceCriteria(code: "3.2c", description: "• Public (if appropriate)"),
                ]
            ),
            LearningOutcome(
                number: "4",
                title: "Know how to verify",
                performanceCriteria: [
                    PerformanceCriteria(code: "4.1", description: "Verify the compatibility of the electrical supply to the requirements of the installation specification"),
                    PerformanceCriteria(code: "4.2", description: "Identify the earthing arrangement for the electrical installation"),
                ]
            ),
            LearningOutcome(
                number: "5",
                title: "Know how to plan locations",
                performanceCriteria: [
                    PerformanceCriteria(code: "5.1", description: "Ensure that the planned locations for the wiring system(s) and its associated equipment are compatible with other site services requirements"),
                    PerformanceCriteria(code: "5.2", description: "Use different measuring and marking out techniques which are appropriate to the wiring system, wiring enclosure and/or associated equipment that is being installed"),
                    PerformanceCriteria(code: "5.3", description: "Ensure that the planned locations are visually acceptable and in accordance with the installation specification"),
                ]
            ),
            LearningOutcome(
                number: "6",
                title: "Know how to produce a planned programme of work",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.1", description: "Produce a planned programme of work for the fitting and fixing of wiring systems, wiring enclosures and associated equipment in accordance with:"),
                    PerformanceCriteria(code: "6.1a", description: "• A safe system of work"),
                    PerformanceCriteria(code: "6.1b", description: "• Co-ordination with other site services"),
                    PerformanceCriteria(code: "6.1c", description: "• Relevant regulations (e.g. iee wiring regulations; building regulations)"),
                    PerformanceCriteria(code: "6.1d", description: "• Installation specification"),
                    PerformanceCriteria(code: "6.1e", description: "• Manufacturers' instructions"),
                ]
            ),
            LearningOutcome(
                number: "6.2",
                title: "Know how to install",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.2", description: "Install the following in accordance with the iee wiring regulations, the installation specification and agreed planned programme of work:"),
                    PerformanceCriteria(code: "6.2a", description: "• Thermosetting insulated cables including flexes"),
                    PerformanceCriteria(code: "6.2b", description: "• Single and multicore thermoplastic (pvc) and thermosetting insulated cables*"),
                    PerformanceCriteria(code: "6.2c", description: "• Pvc/pvc flat profile cable*"),
                    PerformanceCriteria(code: "6.2d", description: "• Micc (with and without pvc sheath)"),
                    PerformanceCriteria(code: "6.2e", description: "• Swa cables (pilc, xlpe, pvc)*"),
                    PerformanceCriteria(code: "6.2f", description: "• Armoured/braided flexible cables and cords"),
                    PerformanceCriteria(code: "6.2g", description: "• Data cables"),
                    PerformanceCriteria(code: "6.2h", description: "• Fibre optic cable"),
                    PerformanceCriteria(code: "6.2i", description: "• Fire resistant cable*"),
                ]
            ),
            LearningOutcome(
                number: "6.3",
                title: "Know how to install",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.3", description: "Install the following in accordance with the iee wiring regulations, the installation specification and agreed planned programme of work:"),
                    PerformanceCriteria(code: "6.3a", description: "• Conduit (pvc and metallic)*"),
                    PerformanceCriteria(code: "6.3b", description: "• Trunking (pvc and metallic)*"),
                    PerformanceCriteria(code: "6.3c", description: "• Cable tray*"),
                    PerformanceCriteria(code: "6.3d", description: "• Cable basket"),
                    PerformanceCriteria(code: "6.3e", description: "• Ladder systems"),
                    PerformanceCriteria(code: "6.3f", description: "• Ducting"),
                    PerformanceCriteria(code: "6.3g", description: "• Modular wiring systems"),
                    PerformanceCriteria(code: "6.3h", description: "• Busbar systems and powertrack"),
                ]
            ),
            LearningOutcome(
                number: "6.4",
                title: "Know how to determine cable carrying capacity",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.4", description: "Determine the cable carrying capacity of conduit, trunking and ducting in accordance with the iee wiring regulations and the installation specification"),
                ]
            ),
            LearningOutcome(
                number: "6.5",
                title: "Know how to install electrical equipment and accessories",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.5", description: "Install the following types of electrical equipment and accessories, in accordance with the iee wiring regulations, the installation specification, manufacturers' instructions and the agreed planned programme of work:"),
                    PerformanceCriteria(code: "6.5a", description: "• Isolators and switches"),
                    PerformanceCriteria(code: "6.5b", description: "• Socket-outlets"),
                    PerformanceCriteria(code: "6.5c", description: "• Distribution-boards"),
                    PerformanceCriteria(code: "6.5d", description: "• Consumer units"),
                    PerformanceCriteria(code: "6.5e", description: "• Earthing fault and over current protective devices"),
                    PerformanceCriteria(code: "6.5f", description: "• Luminaires"),
                    PerformanceCriteria(code: "6.5g", description: "• Control equipment"),
                    PerformanceCriteria(code: "6.5h", description: "• Data socket outlets"),
                    PerformanceCriteria(code: "6.5i", description: "• Auxiliary equipment (e.g. heating/water system components)"),
                ]
            ),
            LearningOutcome(
                number: "6.6",
                title: "Know how to dispose of unwanted material and equipment",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.6", description: "Dispose of unwanted material and equipment in accordance with site procedures and statutory requirement"),
                ]
            ),
            LearningOutcome(
                number: "7",
                title: "Know how to confirm variations",
                performanceCriteria: [
                    PerformanceCriteria(code: "7.1", description: "Confirm that, where variations to the installation specification and/or work programme have been identified, appropriate action has been taken after agreement of relevant persons (e.g. customer; client; site manager)"),
                    PerformanceCriteria(code: "7.2", description: "Verify that that the completed system meets specified requirements in terms of ensuring that components and equipment of the correct type, fit for purpose and are installed in accordance with the iee wiring regulations, the installation specification and, as appropriate, with manufacturer instructions")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence, .workRecords]
    ),

    // Unit 316
    Unit(
        code: "316",
        eltCode: "ELTP05",
        reference: "316",
        title: "Terminating and connecting conductors, cables and flexible cords in electrical systems",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .performance,
        creditValue: 8,
        glh: 4,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know how to carry out safe isolation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Carry out safe isolation safe isolation of electrical circuits and complete electrical installations in accordance with regulatory requirements"),
                    PerformanceCriteria(code: "1.2", description: "Ensure the health and safety of themselves and others within the work location in terms of:"),
                    PerformanceCriteria(code: "1.2a", description: "• Selection and use of tools"),
                    PerformanceCriteria(code: "1.2b", description: "• PPE"),
                    PerformanceCriteria(code: "1.2c", description: "• Risk assessment"),
                    PerformanceCriteria(code: "1.2d", description: "• Reporting of unsafe situations"),
                    PerformanceCriteria(code: "1.2e", description: "• Adherence to relevant statutory and non-statutory regulations"),
                ]
            ),
            LearningOutcome(
                number: "1.3",
                title: "Know how to check safety",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.3", description: "Check the safety of electrical systems and equipment prior to the completion of termination and connections in terms of:"),
                    PerformanceCriteria(code: "1.3a", description: "• Presence of supply"),
                    PerformanceCriteria(code: "1.3b", description: "• Mechanical soundness"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know how to terminate and connect",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Terminate and connect conductors, cables and flexible cords in accordance with the installation specification, manufacturer instructions and iee wiring regulations"),
                    PerformanceCriteria(code: "2.2", description: "Connect to electrical equipment and accessories, in accordance with the installation specification, manufacturer instructions and iee wiring regulations"),
                    PerformanceCriteria(code: "2.3", description: "Terminate and connect conductors, cables and cords using the following techniques:"),
                    PerformanceCriteria(code: "2.3a", description: "• Screwing"),
                    PerformanceCriteria(code: "2.3b", description: "• Crimping"),
                    PerformanceCriteria(code: "2.3c", description: "• Soldering"),
                    PerformanceCriteria(code: "2.3d", description: "• Non-screw compression"),
                ]
            ),
            LearningOutcome(
                number: "2.1",
                title: "Know how to terminate",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1a", description: "• Thermosetting insulated cables including flexes"),
                    PerformanceCriteria(code: "2.1b", description: "• Single and multicore thermoplastic (pvc)* and thermosetting insulated cables"),
                    PerformanceCriteria(code: "2.1c", description: "• Pvc/pvc flat profile cable*"),
                    PerformanceCriteria(code: "2.1d", description: "• Micc (with and without pvc sheath)"),
                    PerformanceCriteria(code: "2.1e", description: "• Swa cables (pilc, xlpe, pvc)*"),
                    PerformanceCriteria(code: "2.1f", description: "• Armoured/braided flexible cables and cords"),
                    PerformanceCriteria(code: "2.1g", description: "• Data cables"),
                    PerformanceCriteria(code: "2.1h", description: "• Fibre optic cable"),
                    PerformanceCriteria(code: "2.1i", description: "• Fire resistant cable*"),
                ]
            ),
            LearningOutcome(
                number: "2.2",
                title: "Know how to connect",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.2a", description: "• Socket-outlets"),
                    PerformanceCriteria(code: "2.2b", description: "• Distribution-boards"),
                    PerformanceCriteria(code: "2.2c", description: "• Consumer units"),
                    PerformanceCriteria(code: "2.2d", description: "• Luminaires"),
                    PerformanceCriteria(code: "2.2e", description: "• Electric motors and their control equipment"),
                    PerformanceCriteria(code: "2.2f", description: "• Circuit breakers"),
                    PerformanceCriteria(code: "2.2g", description: "• Earthing terminals"),
                    PerformanceCriteria(code: "2.2h", description: "• Control panels"),
                    PerformanceCriteria(code: "2.2i", description: "• Data socket outlets"),
                    PerformanceCriteria(code: "2.2j", description: "• Auxiliary equipment (eg heating system components)"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know how to ensure terminations and connections are safe",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Ensure that terminations and connections are electrically and mechanically sound"),
                    PerformanceCriteria(code: "3.2", description: "Complete the necessary identification of cables, conductors and flexible cords in accordance with regulatory requirements and organisational procedures"),
                    PerformanceCriteria(code: "3.3", description: "Dispose of unwanted material and equipment in accordance with site procedures and statutory requirements")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence, .workRecords]
    ),

    // Unit 317
    Unit(
        code: "317",
        eltCode: "ELTP06",
        reference: "317",
        title: "Inspecting, testing, commissioning and certifying electrotechnical systems and equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .performance,
        creditValue: 12,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know how to carry out safe isolation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures"),
                    PerformanceCriteria(code: "1.2", description: "Ensure health and safety during inspection and testing"),
                    PerformanceCriteria(code: "1.3", description: "Check safety of electrical systems prior to testing"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know how to inspect",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Assess if safe system of work is appropriate"),
                    PerformanceCriteria(code: "2.2", description: "Carry out visual inspection according to regulations"),
                    PerformanceCriteria(code: "2.3", description: "Complete schedule of inspections"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know how to test",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Select appropriate test instruments"),
                    PerformanceCriteria(code: "3.2", description: "Carry out tests according to regulations"),
                    PerformanceCriteria(code: "3.3", description: "Verify and report test results"),
                ]
            ),
            LearningOutcome(
                number: "4",
                title: "Know how to commission",
                performanceCriteria: [
                    PerformanceCriteria(code: "4.1", description: "Clarify commissioning procedures"),
                    PerformanceCriteria(code: "4.2", description: "Commission according to specifications"),
                    PerformanceCriteria(code: "4.3", description: "Demonstrate operation to client"),
                    PerformanceCriteria(code: "4.4", description: "Complete handover documentation")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence, .workRecords]
    ),

    // Unit 318
    Unit(
        code: "318",
        eltCode: "ELTP07",
        reference: "318",
        title: "Diagnosing and correcting electrical faults in electrical systems and equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .performance,
        creditValue: 12,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know how to carry out safe isolation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Carry out safe isolation procedures"),
                    PerformanceCriteria(code: "1.2", description: "Ensure health and safety during fault diagnosis"),
                    PerformanceCriteria(code: "1.3", description: "Use appropriate warning notices"),
                    PerformanceCriteria(code: "1.4", description: "Check system safety before diagnosis"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know how to diagnose",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Gather information about reported faults"),
                    PerformanceCriteria(code: "2.2", description: "Use system specifications"),
                    PerformanceCriteria(code: "2.3", description: "Report potential disruption"),
                    PerformanceCriteria(code: "2.4", description: "Assess safe working practices"),
                    PerformanceCriteria(code: "2.5", description: "Perform diagnostic tests"),
                    PerformanceCriteria(code: "2.6", description: "Use appropriate fault location methods"),
                    PerformanceCriteria(code: "2.7", description: "Use test instruments correctly"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know how to correct",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Confirm repairs with relevant people"),
                    PerformanceCriteria(code: "3.2", description: "Perform fault correction safely"),
                    PerformanceCriteria(code: "3.3", description: "Replace components correctly"),
                    PerformanceCriteria(code: "3.4", description: "Ensure system safety if fault persists"),
                    PerformanceCriteria(code: "3.5", description: "Test after fault correction"),
                    PerformanceCriteria(code: "3.6", description: "Record and report results")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence, .workRecords]
    ),

    // Unit 399
    Unit(
        code: "399",
        eltCode: "ELT OC1",
        reference: "399",
        title: "Electrotechnical occupational competence",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .performance,
        creditValue: 6,
        glh: 4,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know professional competence",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Demonstrate professional working practices"),
                    PerformanceCriteria(code: "1.2", description: "Apply technical knowledge"),
                    PerformanceCriteria(code: "1.3", description: "Follow industry standards"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know technical skills",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Complete installations to standards"),
                    PerformanceCriteria(code: "2.2", description: "Test and commission systems"),
                    PerformanceCriteria(code: "2.3", description: "Diagnose and correct faults"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Complete required documentation"),
                    PerformanceCriteria(code: "3.2", description: "Maintain accurate records"),
                    PerformanceCriteria(code: "3.3", description: "Process technical information")
                ]
            )
        ],
        allowedAssessmentMethods: [.directObservation, .productEvidence, .professionalDiscussion]
    ),

    // Knowledge Units
    Unit(
        code: "601",
        eltCode: "ELTK01",
        reference: "601",
        title: "Understanding Health and Safety legislation, practices and procedures",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 54,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know health and safety legislation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand health and safety legislation"),
                    PerformanceCriteria(code: "1.2", description: "Explain employer and employee responsibilities"),
                    PerformanceCriteria(code: "1.3", description: "Describe risk assessment requirements"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know safe working practices",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain safe working procedures"),
                    PerformanceCriteria(code: "2.2", description: "Describe PPE requirements"),
                    PerformanceCriteria(code: "2.3", description: "Outline hazard control measures"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know emergency procedures",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Explain emergency response procedures"),
                    PerformanceCriteria(code: "3.2", description: "Describe first aid requirements"),
                    PerformanceCriteria(code: "3.3", description: "Outline incident reporting procedures")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 602
    Unit(
        code: "602",
        eltCode: "ELTK02",
        reference: "602",
        title: "Understanding environmental legislation, working practices and the principles of environmental technology systems",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 36,
        glh: 4,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know environmental legislation",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand environmental protection legislation"),
                    PerformanceCriteria(code: "1.2", description: "Explain waste management requirements"),
                    PerformanceCriteria(code: "1.3", description: "Describe pollution control measures"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know environmental technologies",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain renewable energy systems"),
                    PerformanceCriteria(code: "2.2", description: "Describe energy efficiency measures"),
                    PerformanceCriteria(code: "2.3", description: "Outline sustainable practices")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 603
    Unit(
        code: "603",
        eltCode: "ELTK03",
        reference: "603",
        title: "Understanding the practices and procedures for overseeing and organising the work environment",
        description: "Electrical Installation",
        unitType: .knowledge,
        creditValue: 56,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know work planning principles",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand work planning principles"),
                    PerformanceCriteria(code: "1.2", description: "Explain resource management"),
                    PerformanceCriteria(code: "1.3", description: "Describe coordination requirements"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know quality control",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain quality assurance procedures"),
                    PerformanceCriteria(code: "2.2", description: "Describe monitoring methods"),
                    PerformanceCriteria(code: "2.3", description: "Outline documentation requirements")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 604
    Unit(
        code: "604",
        eltCode: "ELTK04a",
        reference: "604",
        title: "Understanding the principles of planning and selection for the installation of electrotechnical equipment and systems in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 76,
        glh: 8,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know installation specifications",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Interpret specifications and technical data for the installation of:"),
                    PerformanceCriteria(code: "1.1a", description: "• Protective earthing systems"),
                    PerformanceCriteria(code: "1.1b", description: "• A ring final circuit"),
                    PerformanceCriteria(code: "1.1c", description: "• A general lighting circuit"),
                    PerformanceCriteria(code: "1.1d", description: "• A control system for a three-phase motor"),
                    PerformanceCriteria(code: "1.1e", description: "• A central heating/sustainable energy system"),
                    PerformanceCriteria(code: "1.1f", description: "• A safety service circuit"),
                    PerformanceCriteria(code: "1.1g", description: "• A data cabling system"),
                    PerformanceCriteria(code: "1.1h", description: "• A three-phase socket-outlet"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know risk assessment",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Review safe working practices"),
                    PerformanceCriteria(code: "2.2", description: "Undertake a risk assessment"),
                    PerformanceCriteria(code: "2.3", description: "Complete risk assessment documentation in accordance with organisational procedures"),
                ]
            ),
            LearningOutcome(
                number: "3",
                title: "Know safe isolation",
                performanceCriteria: [
                    PerformanceCriteria(code: "3.1", description: "Locate correct means of isolation"),
                    PerformanceCriteria(code: "3.2", description: "Follow correct procedures for the isolation of electrical circuit(s) and complete electrical installations"),
                    PerformanceCriteria(code: "3.3", description: "Isolate circuit (s) in correct sequence"),
                    PerformanceCriteria(code: "3.4", description: "Select correct test and measuring instruments"),
                    PerformanceCriteria(code: "3.5", description: "Correctly test for the presence of an electrical supply"),
                ]
            ),
            LearningOutcome(
                number: "4",
                title: "Know selection",
                performanceCriteria: [
                    PerformanceCriteria(code: "4.1", description: "Select the correct cables, accessories, equipment, components and protective devices for installations"),
                    PerformanceCriteria(code: "4.1a", description: "Protective earthing systems"),
                    PerformanceCriteria(code: "4.1b", description: "Ring final circuit"),
                    PerformanceCriteria(code: "4.1c", description: "General lighting circuit"),
                    PerformanceCriteria(code: "4.1d", description: "Control of a three-phase motor"),
                    PerformanceCriteria(code: "4.1e", description: "Central heating/sustainable energy system"),
                    PerformanceCriteria(code: "4.1f", description: "Safety service circuit"),
                    PerformanceCriteria(code: "4.1g", description: "Data cabling system"),
                    PerformanceCriteria(code: "4.1h", description: "Three-phase socket-outlet"),
                    PerformanceCriteria(code: "4.2", description: "Select appropriate isolators"),
                    PerformanceCriteria(code: "4.3", description: "Select appropriate socket outlets"),
                    PerformanceCriteria(code: "4.4", description: "Select appropriate overcurrent protection devices"),
                ]
            ),
            LearningOutcome(
                number: "5",
                title: "Know installation",
                performanceCriteria: [
                    PerformanceCriteria(code: "5.1a", description: "In accordance with an installation specification install, terminate and connect cables, accessories, equipment, components and protective devices for the installation of: • Protective earthing systems"),
                    PerformanceCriteria(code: "5.1b", description: "• A ring final circuit"),
                    PerformanceCriteria(code: "5.1c", description: "• A general lighting circuit"),
                    PerformanceCriteria(code: "5.1d", description: "• The control of a three-phase motor"),
                    PerformanceCriteria(code: "5.1e", description: "• A central heating/sustainable energy system"),
                    PerformanceCriteria(code: "5.1f", description: "• A safety service circuit"),
                    PerformanceCriteria(code: "5.1g", description: "• A data cabling system"),
                    PerformanceCriteria(code: "5.1h", description: "• A three-phase socket-outlet"),
                ]
            ),
            LearningOutcome(
                number: "6",
                title: "Know documentation",
                performanceCriteria: [
                    PerformanceCriteria(code: "6.1", description: "Comply with correct procedures"),
                    PerformanceCriteria(code: "6.2", description: "Record relevant findings on correct documentation"),
                ]
            ),
            LearningOutcome(
                number: "7",
                title: "Know testing",
                performanceCriteria: [
                    PerformanceCriteria(code: "7.1", description: "Select and use the correct measuring instruments"),
                    PerformanceCriteria(code: "7.2", description: "Confirm instruments function accurately"),
                    PerformanceCriteria(code: "7.3", description: "Measure the continuity of protective conductors"),
                    PerformanceCriteria(code: "7.4", description: "Measure the continuity of ring final circuit conductors"),
                    PerformanceCriteria(code: "7.5", description: "Measure the insulation resistance of the installation and its circuits"),
                    PerformanceCriteria(code: "7.6", description: "Confirm the polarity of the installation's electrical outlets and components"),
                    PerformanceCriteria(code: "7.7", description: "Determine the installation's earth fault-loop impedance (efli)"),
                    PerformanceCriteria(code: "7.8", description: "Determine the installation's prospective fault current (pfc)"),
                    PerformanceCriteria(code: "7.9", description: "Carry out functional tests on the installation's equipment and components"),
                    PerformanceCriteria(code: "7.10", description: "Complete the correct documentation in accordance with statutory and non-statutory regulations"),
                ]
            ),
            LearningOutcome(
                number: "8",
                title: "Know fault finding",
                performanceCriteria: [
                    PerformanceCriteria(code: "8.1", description: "Undertake an assessment of risk accordingly"),
                    PerformanceCriteria(code: "8.2", description: "Carry out safe isolation in the correct sequence as appropriate to fault diagnosis procedures"),
                    PerformanceCriteria(code: "8.3", description: "Select and use correctly, fit for purpose tools, equipment and instruments"),
                    PerformanceCriteria(code: "8.4", description: "Carry out relevant checks and preparations"),
                    PerformanceCriteria(code: "8.5", description: "Locate faults from given information"),
                    PerformanceCriteria(code: "8.6", description: "State how the identified faults can be rectified")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 605
    Unit(
        code: "605",
        eltCode: "ELTK04",
        reference: "605",
        title: "Understanding the practices and procedures for the preparation and installation of wiring systems and electrotechnical equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 96,
        glh: 10,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know installation practices",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand installation methods"),
                    PerformanceCriteria(code: "1.2", description: "Explain wiring systems"),
                    PerformanceCriteria(code: "1.3", description: "Describe equipment installation"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know technical standards",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain technical requirements"),
                    PerformanceCriteria(code: "2.2", description: "Describe installation regulations"),
                    PerformanceCriteria(code: "2.3", description: "Outline quality standards")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 606
    Unit(
        code: "606",
        eltCode: "ELTK05",
        reference: "606",
        title: "Understanding the principles, practices and legislation for the termination and connection of conductors, cables and cords in electrical systems",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 86,
        glh: 9,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know termination principles",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand termination methods"),
                    PerformanceCriteria(code: "1.2", description: "Explain connection techniques"),
                    PerformanceCriteria(code: "1.3", description: "Describe cable preparation"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know technical requirements",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain technical specifications"),
                    PerformanceCriteria(code: "2.2", description: "Describe safety requirements"),
                    PerformanceCriteria(code: "2.3", description: "Outline testing procedures")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 607
    Unit(
        code: "607",
        eltCode: "ELTK06",
        reference: "607",
        title: "Understanding principles, practices and legislation for the inspection, testing, commissioning and certification of electrotechnical systems and equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 78,
        glh: 8,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know testing principles",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand testing requirements"),
                    PerformanceCriteria(code: "1.2", description: "Explain inspection procedures"),
                    PerformanceCriteria(code: "1.3", description: "Describe commissioning process"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know certification",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain certification requirements"),
                    PerformanceCriteria(code: "2.2", description: "Describe documentation standards"),
                    PerformanceCriteria(code: "2.3", description: "Outline regulatory compliance")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 608
    Unit(
        code: "608",
        eltCode: "ELTK07",
        reference: "608",
        title: "Understanding the principles, practices and legislation for diagnosing and correcting electrical faults in electrotechnical systems and equipment in buildings, structures and the environment",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 58,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know diagnostic principles",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand diagnostic principles"),
                    PerformanceCriteria(code: "1.2", description: "Explain fault finding techniques"),
                    PerformanceCriteria(code: "1.3", description: "Describe testing methods"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know repair procedures",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain repair procedures"),
                    PerformanceCriteria(code: "2.2", description: "Describe safety requirements"),
                    PerformanceCriteria(code: "2.3", description: "Outline documentation needs")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    ),

    // Unit 609
    Unit(
        code: "609",
        eltCode: "ELTK08",
        reference: "609",
        title: "Understanding the electrical principles associated with the design, building, installation and maintenance of electrical equipment and systems",
        description: "Installing and maintaining electrotechnical systems and equipment",
        unitType: .knowledge,
        creditValue: 58,
        glh: 6,
        startDate: DateHelper.getStandardDateRange().start,
        endDate: DateHelper.getStandardDateRange().end,
        learningOutcomes: [
            LearningOutcome(
                number: "1",
                title: "Know electrical theory",
                performanceCriteria: [
                    PerformanceCriteria(code: "1.1", description: "Understand electrical theory"),
                    PerformanceCriteria(code: "1.2", description: "Explain circuit principles"),
                    PerformanceCriteria(code: "1.3", description: "Describe system design"),
                ]
            ),
            LearningOutcome(
                number: "2",
                title: "Know technical applications",
                performanceCriteria: [
                    PerformanceCriteria(code: "2.1", description: "Explain practical applications"),
                    PerformanceCriteria(code: "2.2", description: "Describe maintenance requirements"),
                    PerformanceCriteria(code: "2.3", description: "Outline safety considerations")
                ]
            )
        ],
        allowedAssessmentMethods: [.professionalDiscussion, .productEvidence]
    )
] 
