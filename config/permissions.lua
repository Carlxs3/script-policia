-- NOTE: The key here uses Config.PoliceJobName so renaming the job in _framework.lua is enough.
-- If you add extra police jobs (e.g. sheriff), add their own block below using their exact job name.
Config.Permissions = {
    [Config.PoliceJobName] = {
        --Tabs
        Dispatch = 0,
        SearchCitizen = 0,
        SearchReports = 0,
        SearchVehicles = 0,
        CriminalCode = 0,
        SearchCapture = 0,
        SearchDebtors = 0,
        FederalManagement = 0,
        AgentManagement = 11,
        SecurityCamera = 1,
        Radio = 0,
        TimeControl = 11,

        -- DISPATCH
        MovePlayerInRadio = 7,
        EnterRadioFreq = 0,
        SendRadioMessage = 0,
        AddNotesToAlert = 0,
        AssignAlertToUnit = 1,

        -- SEARCH CITIZEN
        SetWanted = 0,
        SetDanger = 0,
        CreateNotes = 0,
        PinNotes = 0,
        DeleteNotes = 7,
        CreateBill = 0,
        DeleteBill = 7,
        AddLicenses = 7,
        DeleteLicenses = 7,

        -- REPORTS
        CreateReport = 0,
        AddPeopleToReport = 0,
        AddBillReport = 0,
        RemovePeopleFromReport = 7,
        AddEvidence = 1,
        DeleteEvidence = 1,
        AddReportAgent = 0,
        AddTags = 0,
        RemoveTags = 7,
        AddVictimToReport = 0,
        AddVehicleToReport = 0,
        DeleteReport = 7,

        -- AddFederal
        AddFederal = 7,

        -- SecurityCameras
        SeeBusinessCameras = 11,
        SeeVehicleCamera = 11,
        SeeBodyCams = 11,

        -- PoliceManagement
        GenerateBadge = 11,
        AddPolice = 11,
        ChangePoliceGrade = 11,
        ChangePoliceBadge = 11,
        AddCondecorate = 11,
        RemoveCondecorate = 11,
        AddDivision = 11,
        RemoveDivision = 11,
        HirePolice = 11,

        -- Shapes
        Operations = 7,
        CreateShape = 7,
        DeleteShape = 7,

        -- RIGHT MENU
        RadialCommunicationTab = 0,
        RadioTab = 0,
        InteractTab = 0,
        HolsterTab = 0,
        ObjectPlacementTab = 0,
        CanTackle = 0,
    },
    ["ambulance"] = {
        --Tabs
        Dispatch = 1,
        SearchCitizen = 1,
        SearchReports = 1,
        SearchVehicles = 99,
        CriminalCode = 3,
        SearchCapture = 99,
        SearchDebtors = 99,
        FederalManagement = 99,
        AgentManagement = 3,
        Radio = 1,
        TimeControl = 1,

        -- DISPATCH
        MovePlayerInRadio = 4,
        EnterRadioFreq = 1,
        SendRadioMessage = 1,
        AddNotesToAlert = 1,
        AssignAlertToUnit = 3,

        -- SEARCH CITIZEN
        SetWanted = 4,
        SetDanger = 1,
        CreateNotes = 1,
        PinNotes = 4,
        DeleteNotes = 4,
        CreateBill = 1,
        DeleteBill = 4,
        AddLicenses = 99,
        DeleteLicenses = 99,

        -- REPORTS
        CreateReport = 1,
        AddPeopleToReport = 1,
        AddBillReport = 1,
        RemovePeopleFromReport = 1,
        AddEvidence = 1,
        DeleteEvidence = 1,
        AddReportAgent = 1,
        AddTags = 1,
        RemoveTags = 1,
        AddVictimToReport = 1,
        AddVehicleToReport = 1,
        DeleteReport = 3,

        -- AddFederal
        AddFederal = 99,

        -- SecurityCameras
        SeeBusinessCameras = 99,
        SeeVehicleCamera = 99,
        SeeBodyCams = 99,

        -- PoliceManagement
        GenerateBadge = 99,
        AddPolice = 99,
        ChangePoliceGrade = 99,
        ChangePoliceBadge = 99,
        AddCondecorate = 99,
        RemoveCondecorate = 99,
        AddDivision = 99,
        RemoveDivision = 99,
        HirePolice = 99,

        -- Shapes
        Operations = 99,
        CreateShape = 99,
        DeleteShape = 99,

        -- RIGHT MENU
        RadialCommunicationTab = 1,
        RadioTab = 1,
        InteractTab = 1,
        HolsterTab = 1,
        ObjectPlacementTab = 1,
        CanTackle = 99,
    },
}

Config.PermissionsGroups = {
    "mod", "admin", "superadmin", "god" -- list of groups that will have all permissions, like "mod", "admin", "superadmin", etc
}

-- DONT TOUCH ANYTHING BELOW THIS LINE
exports("GerPermissions", function()
    return Config.Permissions
end)

if not Config.JobCategory[Config.PoliceJobCategory] then
    print("Looks like you have a wrong police job category setted in the Config.PoliceJobCategory option, please check the config/permissions.lua file")
end