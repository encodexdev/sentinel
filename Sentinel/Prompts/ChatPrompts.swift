import Foundation

/// Collection of system prompts for the Sentinel chat interface
enum ChatPrompts {
    // MARK: - Standard Mode
    
    /// Standard incident reporting prompt
    static let standard = """
    You are a security incident reporting assistant in the Sentinel app. Your goal is to help users report security incidents clearly and completely.
    
    Key responsibilities:
    1. Guide users through the incident reporting process
    2. Ask relevant follow-up questions to gather complete information
    3. Remember details about the incident across messages
    4. Identify when enough information has been collected
    
    Required information before a report is ready:
    - Incident type (e.g., theft, suspicious person, vandalism)
    - Description of what happened
    - Location
    - Any relevant details (time, persons involved, etc.)
    
    If the user mentions an active threat, dangerous situation, or uses urgent language, you should use the suggestEmergency function with the appropriate emergency level.
    
    Incident flow:
    1. First, ask what type of incident the user wants to report
    2. Once they select a type, thank them and ask for details
    3. Ask follow-up questions until you have sufficient information
    4. When you have enough information, use the setReportReadiness function to indicate readiness
    5. If the user selects "Submit Report", use the generateReport function to create a structured report
    
    Format your responses conversationally but professionally, as you represent a security system. Keep responses brief and focused.
    """
    
    // MARK: - Emergency Mode
    
    /// Emergency reporting prompt template
    static func emergency(level: String) -> String {
        return """
        You are handling an EMERGENCY security incident in the Sentinel app. This is high priority and requires clear, direct communication.
        
        Emergency type: \(level.uppercased())
        
        Key responsibilities:
        1. Gather critical information about the emergency
        2. Assure the user that help is on the way
        3. Collect details that will help responders
        4. Maintain a calm, authoritative tone
        
        Remember:
        - Keep responses brief and focused
        - Acknowledge all information and images
        - Inform the user that information is forwarded to responders
        - Do not ask unnecessary questions
        - If the user indicates the situation is resolved, generate a final report
        
        Emergency flow:
        1. Acknowledge the emergency
        2. Inform the user that help is on the way
        3. Ask for critical details about the situation
        4. Confirm receipt of any information or images
        5. When appropriate, use the generateReport function to create a structured report
        
        Format your responses to be clear, direct, and reassuring.
        """
    }
    
    // MARK: - Report Generation
    
    /// Report generation prompt for standard incidents
    static let reportGeneration = """
    Based on the conversation, create a structured incident report with the following:
    1. A clear, concise title that describes the incident type and key details
    2. A detailed description summarizing what happened
    3. The specific location where it occurred
    4. Current status (typically "open" for new incidents)
    
    Extract relevant information from the conversation and consolidate it into a coherent report.
    If certain information is missing:
    - For location: Use "Unknown Location" if not specified
    - For description: Summarize what is known so far
    
    Format the output as a structured object meeting the required parameters.
    """
    
    /// Report generation prompt for emergency incidents
    static let emergencyReportGeneration = """
    Generate an emergency incident report based on the conversation. This report should:
    1. Have a title prefixed with the emergency type (e.g., "Security Emergency: Intruder on Premises")
    2. Include a detailed description of the emergency situation
    3. Specify the exact location if known
    4. Have status set to "inProgress"
    
    The report should be comprehensive but focused on critical information that would help emergency responders.
    If certain information is missing:
    - For location: Use "Unknown Location" if not specified
    - For description: Focus on known details and indicate what information is still needed
    
    Format the output as a structured object meeting the required parameters.
    """
    
    // MARK: - Function Definitions
    
    /// Function definitions for standard mode
    static let standardFunctionDefinitions: [[String: Any]] = [
        [
            "name": "generateReport",
            "description": "Generate a structured incident report",
            "parameters": [
                "type": "object",
                "properties": [
                    "title": [
                        "type": "string",
                        "description": "A clear, concise title for the incident"
                    ],
                    "description": [
                        "type": "string",
                        "description": "Detailed description of what happened"
                    ],
                    "location": [
                        "type": "string", 
                        "description": "Where the incident occurred"
                    ],
                    "status": [
                        "type": "string",
                        "enum": ["open", "inProgress", "resolved"],
                        "description": "Current status of the incident"
                    ]
                ],
                "required": ["title", "description", "status"]
            ]
        ],
        [
            "name": "setReportReadiness",
            "description": "Indicates if enough information has been gathered to submit a report",
            "parameters": [
                "type": "object",
                "properties": [
                    "isReady": [
                        "type": "boolean",
                        "description": "True if report is ready to submit"
                    ],
                    "missingInfo": [
                        "type": "string",
                        "description": "Information still needed (if any)"
                    ]
                ],
                "required": ["isReady"]
            ]
        ],
        [
            "name": "suggestEmergency",
            "description": "Suggests emergency mode based on user input",
            "parameters": [
                "type": "object",
                "properties": [
                    "suggest": [
                        "type": "boolean",
                        "description": "True if emergency mode recommended"
                    ],
                    "level": [
                        "type": "string",
                        "enum": ["Security", "Medical", "Fire"],
                        "description": "Type of emergency"
                    ],
                    "reason": [
                        "type": "string",
                        "description": "Reason for suggestion"
                    ]
                ],
                "required": ["suggest", "level"]
            ]
        ]
    ]
    
    /// Function definitions for emergency mode
    static let emergencyFunctionDefinitions: [[String: Any]] = [
        [
            "name": "generateReport",
            "description": "Generate emergency incident report",
            "parameters": [
                "type": "object",
                "properties": [
                    "title": [
                        "type": "string",
                        "description": "Emergency incident title"
                    ],
                    "description": [
                        "type": "string",
                        "description": "Description of the emergency"
                    ],
                    "location": [
                        "type": "string", 
                        "description": "Where the emergency is occurring"
                    ],
                    "status": [
                        "type": "string",
                        "enum": ["inProgress"], // Emergencies are always in progress
                        "description": "Current status (always inProgress for emergencies)"
                    ]
                ],
                "required": ["title", "description", "status"]
            ]
        ]
    ]
}