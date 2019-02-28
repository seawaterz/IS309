/*
CREATE_LOCATION_SP.  Add a new location to the VM_LOCATION table.  
This procedure should take as input location-related attributes and create a 
new location entry.  This procedure does not set the latitude/longitude values, 
only address information a user might provide.  If the country, postalcode, and 
street portion of the address match, then a new location is not added. The 
identifier for the location created or found is returned as an output parameter.

PARAMETERS:  Described below
RETURNS:  a new or existing location_id, using the p_location_id output parameter
ERROR MESSAGES:
  Error text:  "Missing mandatory value for parameter (x).  No location added." 
  Error meaning: A mandatory value is missing.  Here, y = 'CREATE_LOCATION_SP'
  Error effect: Because a mandatory value is not provided, no data are 
    inserted into the VM_LOCATION table.  The p_location_id value returned is 
    NULL.
*/
create or replace procedure CREATE_LOCATION_SP (
                          -- an output parameter
  p_location_country	             VM_LOCATION.LOCATION_COUNTRY%TYPE, 
  p_location_postal_code             VM_LOCATION.LOCATION_POSTAL_CODE%TYPE,
  p_location_street1	             VM_LOCATION.LOCATION_STREET_1%TYPE, 
  p_location_street2	             VM_LOCATION.LOCATION_STREET_2%TYPE, 
  p_location_city	                 VM_LOCATION.LOCATION_CITY%TYPE, 
  p_location_administrative_region   VM_LOCATION.LOCATION_ADMINISTRATIVE_REGION%TYPE
)

IS
ex_error exception;
p_count number (10);
err_msg_txt varchar(100) :=null;
lv_lid_p_location_id NUMBER;
p_location_id  NUMBER;

BEGIN
/*
select count (*)
into p_count 
from VM_LOCATION
WHERE LOCATION_ID = p_location_id;*/

/*
IF p_count > 0
then
err_msg_txt := 'Location is already existed';
raise ex_error; 
IF p_location_id is null THEN
err_msg_txt:= 'LOCATION ID CANNOT BE null';
raise ex_error;*/
IF p_location_country is null or p_location_postal_code is null 
or p_location_street1 is null or p_location_street2 is null or p_location_city is null or p_location_administrative_region is null THEN
err_msg_txt := 'A mandatory value is missing';
raise ex_error; 

end if;

lv_lid_p_location_id := VM_LOCATION_sq.NEXTVAL;

Insert Into VM_LOCATION ("LOCATION_ID", "LOCATION_COUNTRY", "LOCATION_POSTAL_CODE", "LOCATION_STREET_1", "LOCATION_STREET_2", "LOCATION_CITY", "LOCATION_ADMINISTRATIVE_REGION")
VALUES (lv_lid_p_location_id, p_location_country, p_location_postal_code, p_location_street1,  p_location_street2, p_location_city, p_location_administrative_region);  

commit;

p_location_id := lv_lid_p_location_id;

EXCEPTION
WHEN ex_error THEN
dbms_output.put_line (err_msg_txt);
rollback;
WHEN OTHERS THEN
dbms_output.put_line (' THE ERROR CODE IS' || sqlcode);
dbms_output.put_line (' THE ERROR MSG IS' || sqlerrm);
rollback;

END;
/

BEGIN 
CREATE_LOCATION_SP('norway', '6363', 'Dronningensgate 66', 'Dronningensgate 67', 'Kristiansand', 'Vestagder');
commit;
END;
/

/*
CREATE_PERSON_SP.  Add a person to the VM_PERSON table. This procedure can be 
used to add a point of contact for an opportunity or organization, but can also 
be used when adding a member.  The procedure returns the identifier of the newly 
inserted person.  Duplicate email addresses are not permitted.  If a duplicate 
email is found, the procedures returns the identifier associated with that email 
address.  In the latter case, it is not an error for the given name and the 
surname to be NULL.  In this way, the procedure can be used as lookup function,
finding the person_id value for a given email address.

PARAMETERS:  Described below
RETURNS:  a new or existing person_id, using the p_location_id output parameter.  
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x)  in context (y).  No person added." 
    Error meaning: A mandatory value is missing.  Here, y = 'CREATE_PERSON_SP'
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_PERSON table.  The p_person_id value returned 
            is NULL.  
            
    Error text:  "Email address (x) is already used."
    Error effect: Because the email must be unique, no data are inserted into the 
            VM_PERSON data.  The p_person_ID value returned is the one that 
            corresponds to the person already in the table with this email.
*/

create or replace procedure CREATE_PERSON_SP (
    p_person_ID             OUT INTEGER,     -- an output parameter
    p_person_email          IN VARCHAR,  -- Must be unique, not null
    P_person_given_name     IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_surname        IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_phone          IN VARCHAR
)
IS
BEGIN
    NULL;
END;
/

/*
CREATE_MEMBER_SP.  This procedure will create a new member by inserting a row 
into the VM_PERSON and VM_MEMBER tables. The procedure will use 
CREATE_PERSON_SP procedure for the former. The person id generated when 
inserting into the VM_PERSON table will be used as the primary key value for the 
row inserted into the VM_MEMBER table.  The procedure will also call 
CREATE_LOCATION_SP to store the location data provided.

PARAMETERS:  Described below
RETURNS:  a new or existing person_id, identifying the member
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x)  in context (y).  No member added." 
    Error meaning: A mandatory value is missing.  Here, y = 'CREATE_MEMBER_SP'
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_MEMBER table.  The p_person_id value returned 
            is NULL.
            
    Error text: "Invalid value (x) in context (y). No member created."
    Error meaning:  A value for parameter x is not valid.  Here, y = 'CREATE_MEMBER_SP'.
        This could arise if the person_id returned by CREATE_PERSON_SP is not valid,
        or the location_id returned by CREATE_LOCATION_SP is not valid.
            
*/

create or replace procedure CREATE_MEMBER_SP (
    p_person_ID             OUT INTEGER,     -- an output parameter
    p_person_email          IN  VARCHAR,  -- passed through to CREATE_PERSON_SP
    P_person_given_name     IN  VARCHAR,  -- passed through to CREATE_PERSON_SP
    p_person_surname        IN  VARCHAR,  -- passed through to CREATE_PERSON_SP
    p_person_phone          IN  VARCHAR,  -- passed through to CREATE_PERSON_SP
    p_location_country	    IN  VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_location_postal_code  IN	VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_location_street1	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_location_street2	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_location_city	        IN	VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR, -- passed through to CREATE_LOCATION_SP
    p_member_password       IN  VARCHAR   -- NOT NULL  
)
IS
BEGIN
    NULL;
END;
/

/*
CREATE_ORGANIZATION_SP.  Add a new organization to the VM_ORGANIZATION table.  
The contact person data will be used to create a new contact person by calling 
the CREATE_PERSON_SP procedure.  The procedure will also call the 
CREATE_LOCATION_SP procedure to create a new location or use an existing one.

PARAMETERS:  Described below
RETURNS:  a new or existing organization_id, identifying the organization.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x)  in context (y). No organization created." 
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_ORGANIZATION table.  The p_org_id value 
            returned is NULL.  Here, y = 'CREATE_ORGANIZATION_SP'
            
    Error text:  "Invalid value for parameter (x) in context (y).  No organization added."
    Error meaning.  A parameter does not match the domain specification, i.e.
            the organization_type is not one of the permitted values.  
            Here, y = 'CREATE_ORGANIZATION_SP'
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_ORGANIZATION table.  The p_org_id value returned is
            NULL.
            
    Error text:  "Invalid point of contact (x)"
    Error meaning:  The call to the CREATE_PERSON_SP routine has failed to 
        create or retrieve a person_id value.
    Error effect:   Because a valid point of contact cannot be associated with
        the organization, no data are inserted into the VM_ORGANIZATION table. 
        The p_organization_id value returned is NULL.
        
    Error text:  "Invalid location (x)"
    Error meaning:  The call to the CREATE_LOCATION_SP routine has failed to 
        create or retrieve a location_id value.
    Error effect:   Because a valid location cannot be associated with
        the organization, no data are inserted into the VM_ORGANIZATION table. 
        The p_organization_id value returned is NULL.
  
            
*/

create or replace procedure CREATE_ORGANIZATION_SP (
    p_org_id                    OUT INTEGER,    -- output parameter
    p_org_name                  IN VARCHAR,     -- NOT NULL
    p_org_mission               IN VARCHAR,     -- NOT NULL
    p_org_descrip               IN LONG,            
    p_org_phone                 IN VARCHAR,     -- NOT NULL
    p_org_type                  IN VARCHAR,     -- must conform to domain, if it has a value
    p_org_creation_date         IN DATE,            -- IF NULL, use SYSDATE
    p_org_URL                   IN VARCHAR,
    p_org_image_URL             IN VARCHAR,
    p_org_linkedin_URL          IN VARCHAR,
    p_org_facebook_URL          IN VARCHAR,
    p_org_twitter_URL           IN VARCHAR,
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,  -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR   -- passed to CREATE_PERSON_SP
)
IS
BEGIN
    NULL;
END;
/

/*
CREATE_OPPORTUNITY_SP. Add a new opportunity for an organization.  As with other 
procedures, this one will create a contact person by calling CREATE_PERSON_SP, 
and a location by calling CREATE_LOCATION_SP.

PARAMETERS:  Described below
RETURNS:  a new or existing opportunity_id, using the p_opportunity_id output parameter
PARAMETERS:  Described below
RETURNS:  a new or existing opportunity_id, identifying the opportunity.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x) in context (y). No opportunity added." 
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_OPPORTUNITY table.  The p_opportunity_id value 
            returned is NULL.  Here, y = 'CREATE_OPPORTUNITY_SP'
            
    Errors with contact person or location data are generated by 
    CREATE_PERSON_SP and CREATE_LOCATION_SP procedures respectively.
    
    Error text:  "Invalid value for parameter (x) in context (y)  No opportunity added."
    Error meaning.  A parameter does not match the domain specification, i.e.
            the organization_type is not one of the permitted values in this 
            procedure.  Here, y = 'CREATE_OPPORTUNITY_SP'
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_OPPORTUNITY table.  The p_opportunity_id value returned is
            NULL.
           
    Error text:  "Organization (x) not found.  No opportunity added."
    Error meaning:  The value of the p_org_id parameter does not match an 
        existing organization in the VM_ORGANIZATION table.
    Error effect:   Because a valid organization cannot be associated with
        the opportunity, no data are inserted into the VM_OPPORTUNITY table. 
        The p_opp_id value returned is NULL.        
            
    Error text:  "Invalid point of contact (x). No opportunity added."
    Error meaning:  The call to the CREATE_PERSON_SP routine has failed to 
        create or retrieve a person_id value.
    Error effect:   Because a valid point of contact cannot be associated with
        the organization, no data are inserted into the VM_OPPORTUNITY table. 
        The p_opp_id value returned is NULL.
        
*/

create or replace procedure CREATE_OPPORTUNITY_SP (
    p_opp_id                    OUT INTEGER,        -- output parameter
    p_org_id                    IN  INTEGER,        -- NOT NULL
    p_opp_title                 IN  VARCHAR,   -- NOT NULL
    p_opp_description           IN  LONG,       
    p_opp_create_date           IN  DATE,       -- If NULL, use SYSDATE
    p_opp_max_volunteers        IN  INTEGER,    -- If provided, must be > 0
    p_opp_min_volunteer_age     IN  INTEGER,    -- If provided, must be between 0 and 125
    p_opp_start_date            IN  DATE,
    p_opp_start_time            IN  CHAR,       
    p_opp_end_date              IN  DATE,
    p_opp_end_time              IN  CHAR,
    p_opp_status                IN  VARCHAR,    -- If provided, must conform to domain
    p_opp_great_for             IN  VARCHAR,    -- If provided, must conform to domain
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,   -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR    -- passed to CREATE_PERSON_SP    
)
IS
BEGIN
    NULL;
END;
/

/*
ADD_ORG_CAUSE_SP.  Associate a cause with an organization.   Inserts data into 
the VM_ORG_CAUSE table.

PARAMETERS:  Described below
RETURNS:  No values returned.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x) in context (y)"
    Error meaning:  Since both a cause name and an organization id are required, 
        Missing either one causes this error.  Here, y = 'ADD_ORG_CAUSE_SP'.
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_ORG_CAUSE table.
            
    Error text:  "Invalid value for parameter (x) in context (y)."
    Error meaning.  Either the p_cause_name value is not found in VM_CAUSE_NAME,
    or the p_org_id value is not found in the VM_ORGANIZATION table. 
    Here, y = 'ADD_ORG_CAUSE_SP'
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_CAUSE_NAME table.  
*/

create or replace procedure ADD_ORG_CAUSE_SP (
    p_org_id            IN  INTEGER,    -- NOT NULL
    p_cause_name        IN  VARCHAR -- NOT NULL
)
IS
BEGIN
    NULL;
END;
/

/*
ADD_MEMBER_CAUSE_SP.  Associate a cause with a member.  Inserts data into the 
VM_MEMCAUSE table.

PARAMETERS:  Described below
RETURNS:  No values returned.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x) in context (y)"
    Error meaning:  Since both a cause name and an organization id are required, 
        Missing either one causes this error.  Here, y = 'ADD_MEMBER_CAUSE_SP'.
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_ORG_CAUSE table.
            
    Error text:  "Invalid value for parameter (x) in context (y)."
    Error meaning.  Either the p_cause_name value is not found in VM_MEMCAUSE,
    or the p_person_id value is not found in the VM_MEMBER table. 
    Here, y = 'ADD_MEMBER_CAUSE_SP'
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_MEMCAUSE table.  
*/

create or replace procedure ADD_MEMBER_CAUSE_SP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_cause_name    IN  VARCHAR     -- NOT NULL
)
IS
BEGIN
    NULL;
END;
/

/*
ADD_OPP_SKILL_SP.  Associates an opportunity with a required skill.  Inserts 
data into the VM_OPPSKILL table.

PARAMETERS:  Described below
RETURNS:  No values returned.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x) in context (y)"
    Error meaning:  Since both a skill name and an opportunity id are required, 
        Missing either one causes this error.  Here, y = 'ADD_OPP_SKILL_SP'.
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_OPPSKILL table.
            
    Error text:  "Invalid value for parameter (x) in context (y)."
    Error meaning.  Either the p_skill_name value is not found in VM_SKILL,
    or the p_opp_id value is not found in the VM_OPPORTUNITY  table. 
    Here, y = 'ADD_OPP_SKILL_SP'.
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_OPPSKILL table.  
*/

create or replace procedure ADD_OPP_SKILL_SP (
    p_opp_id        IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
)
IS
BEGIN
    NULL;
END;
/

/*
ADD_MEMBER_SKILL_SP.  Associates a member with a required skill. Inserts data 
into the VM_MEMSKILL table.

PARAMETERS:  Described below
RETURNS:  No values returned.
ERROR MESSAGES:
    Error text:  "Missing mandatory value for parameter (x) in context (y)"
    Error meaning:  Since both a skill name and an member's person id are required, 
        Missing either one causes this error.  Here, y = 'ADD_MEMBER_SKILL_SP'.
	Error effect: Because a mandatory value is not provided, no data are 
            inserted into the VM_MEMSKILL table.
            
    Error text:  "Invalid value for parameter (x) in context (y)."
    Error meaning.  Either the p_skill_name value is not found in VM_SKILL,
    or the p_person_id value is not found in the VM_MEMBER  table. 
    Here, y = 'ADD_MEMBER_SKILL_SP'.
    Error effect:  Because a value is invalid, no data are inserted into the
            VM_MEMSKILL table.  
*/

create or replace procedure ADD_MEMBER_SKILL_SP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR -- NOT NULL
)
IS
BEGIN
    NULL;
END;
/