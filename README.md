# Unspecified-Claims-Prototype

## Contents
- [Prerequisites](#prerequisites)
- [Make changes to JSON](#making-changes-to-json)
    - [Adding a new field](#adding-a-new-field)
    - [Show and hide conditions](#show-and-hide-conditions)
    - [List](#fixed-lists)
- [Generate excel from JSON](#generate-excel-file)
- [Upload definition file to environments](#upload-definition-file-to-environments)

## Prerequisites
In order for the generation of the excel spreadsheet the following dependencies must be installed.
- [Docker](https://www.docker.com/)

Follow the above link or if on mac with brew
```$xslt
brew cask install docker
```
- [jq Json Processor](https://stedolan.github.io/jq)

Follow the above link or if on mac with brew
```$xslt
brew install jq
```

## Making changes to JSON

All the JSON files have been added to `definition` directory. Each file represents one tab on the CCD excel file.

### Adding a new field

1) New fields are defined in the `CaseField.json` file. At their most basic they require:
    - `LiveFrom` a live from date - this does nothing in the definition
    - `CaseTypeID` the case type ID that the field belongs to
    - `ID` a unique ID - Field IDs should be understandable
    - `Label` a label that will be rendered in the UI
    - `FieldType` the type of field - a comprehensive list of types can be found [here](https://tools.hmcts.net/confluence/display/RCCD/CCD+Supported+Field+Types).
    - `SecurityClassification` a security classification to allow basic access management - for the prototype this will always be public

    An example of a field:
    ```
    {
        "LiveFrom": "03/12/2019",
        "CaseTypeID": "PrototypeUnspecifiedClaims",
        "ID": "litigationFriend",
        "Label": "Provide litigation friend details",
        "FieldType": "LitigationFriend",
        "SecurityClassification": "Public"
    }
    ```

2) These fields then need to be added to an event in order to appear in the UI. This is done using the `CaseEventToFields.json` file where a `CaseEventID` (defined in `CaseEvents.json`) is linked to a `CaseFieldID`. Within this file you can set:

    - `CaseEventID` the event the field will appear in.
    - `CaseFieldID` the field to appear in the event.
    - `PageFieldDisplayOrder` to define the order the fields will appear on the page.
    - `DisplayContext` either `READONLY`, `OPTIONAL` or `MANDATORY`.
    - `PageID` to define the page and what the final part of the URL will look like - this should be the same value for all fields on the same page.
    - `PageDisplayOrder` to define where the page will appear in the event flow.
    - `ShowSummaryChangeOption` to define if the field should appear in a check your answers still page at the end of the event.

    Example of an entry in `CaseEventToFields.json`:

    ```
    {
        "LiveFrom": "01/12/2019",
        "CaseTypeID": "PrototypeUnspecifiedClaims",
        "CaseEventID": "createClaim",
        "CaseFieldID": "eligibilityQuestions",
        "PageFieldDisplayOrder": 1,
        "DisplayContext": "READONLY",
        "PageID": "Eligibility",
        "PageDisplayOrder": 1,
        "ShowSummaryChangeOption": "N"
    }
    ```

3) The last step for making fields appear is to ensure that the `IDAM` or `Case role` has the correct permissions in the Authorisation files. There are authorisation files for `State`, `CaseType`, `Event`, `Field` and `ComplexTypes`.
   
   `AuthorisationCaseField.json` is used to define CRUD permissions at a field level. If the field is a complex type the permissions you set will be the same for all nested fields.
   
   `AuthorisationComplexTypes.json` is used to define more granular CRUD permissions for each field within a complex type.
   
   - C - Create (required to save a value for the first time)
   - R - Read (required to see a value)
   - U - Update (required to change a value)
   - D - Delete (required to delete an existing value)
   
   For the purpose of the prototype all fields could have all four permissions.
   
   Example of an entry in `AuthorisationCaseField.json`:
   
```
  {
    "LiveFrom": "01/12/2019",
    "CaseTypeID": "PrototypeUnspecifiedClaims",
    "CaseFieldID": "caseName",
    "UserRole": "caseworker-civil",
    "CRUD": "CRUD"
  }
```

### Show and hide conditions

Fields can be shown and hidden using the `FieldShowCondition` column.

Please refer to the [CCD walkthrough of show hide conditions](https://tools.hmcts.net/confluence/display/RCCD/Show+Conditions+and+how+they+work#ShowConditionsandhowtheywork-Contains) for more information.

An example of a field show condition can be found below:

```
"FieldShowCondition": "reachedAgreement = \"No\"",
```

Note: when defining in json it is important to include `\"` before and after the show condition so that the definition process escapes these characters.
In the definition file this will appear as `reachedAgreement = "No"`

#### Case fields

To hide fields within an event use `FieldShowCondition` in `CaseEventToFields.json` to define show hide conditions

#### Complex Types

To hide fields within a complex type use `FieldShowCondition` in `ComplexTypes.json` to define show hide conditions

### Fixed Lists

Fixed list type fields `"FieldType": "FixedList"` are populated using the `FieldTypeParameter` column in ccd definition, 
which is defined in `FixedLists.json` using the `ID` field.
 
 An example entry:
```
  {
    "ID": "PartyType",
    "ListElementCode": "INDIVIDUAL",
    "ListElement": "Individual",
    "DisplayOrder": 1
  },
```

Where 
- `ID` is the ID of the fixed list and what is used for `FieldTypeParameter`
- `ListElementCode` the CCD reference to the specific element (used in show conditions)
- `ListElement` the value the element will have on screen
- `DisplayOrder` the order the elements in the list should be display

`DisplayOrder` should always be set to avoid lists changing order.

### Further reading 

The [CCD definition glossary](https://tools.hmcts.net/confluence/display/RCCD/CCD+Definition+Glossary+for+Setting+up+a+Service+in+CCD) has a wealth of information about what each field in the definition files / tabs represent.

## Generate Excel File

To run this file `Docker` must be up and running. To start this, click on the application and wait for it to be fully up.

To generate a xlsx file from the JSON files run the following command from the project root (unspec-prototype) in the terminal:

```bash
./bin/generate-excel-definition.sh 
```

Use `cd` to navigate through your directories in terminal and `ls` to list all files in a directory.

This will generate a definition file in `excel-definition` directory in the following format:

`unspec-prototype-day-month-year_hour-minute-seconds-commithash.xlsx`

The commit hash will help identify which version is running on which environment.

## Upload definition file to environments

### AAT

To upload definition file to AAT you will first need to connect to VPN.

Follow the below [upload definition URL](https://ccd-admin-web.aat.platform.hmcts.net) and click `Import case definition` link in top left.

To view the uploaded prototype definition go to the [aat environment](http://manage-case.aat.platform.hmcts.net) and select 
- Jurisdiction: `Civil`
- Case type: `Prototype Unspecified Claims`.

### Demo

VPN not required for demo

Follow the below [upload definition URL](http://ccd-admin-web.demo.platform.hmcts.net) and click `Import case definition` link in top left.

To view the prototype definition go to the [demo environment](https://manage-case.demo.platform.hmcts.net/) and select 
- Jurisdiction: `Civil`
- Case type: `Prototype Unspecified Claims`.



