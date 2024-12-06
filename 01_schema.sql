-- SCHEMA FILE for OPAL DATA

DROP SCHEMA IF EXISTS opaltravel cascade;

CREATE SCHEMA opaltravel;

SET SCHEMA 'opaltravel';

DROP TABLE IF EXISTS Trips;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS UserRoles;
DROP TABLE IF EXISTS Stations;
DROP TABLE IF EXISTS StationTypes;
DROP TABLE IF EXISTS OpalCards;
DROP TABLE IF EXISTS CardTypes;
DROP TABLE IF EXISTS TravelTimes;
DROP TABLE IF EXISTS CardLimit;

-- UserRoles: userroleid, rolename, isAdmin, (privilegeFlags?) 
CREATE TABLE UserRoles (
    userroleid serial PRIMARY KEY,
    rolename text,
    isAdmin boolean NOT NULL,
    privilegeFlags bigint
);

-- Users: userid, cardid, firstname, lastname, preferredname, userroleid, password
CREATE TABLE Users (
    userid serial PRIMARY KEY,  
    firstname text, 
    lastname text, 
    userroleid bigint REFERENCES UserRoles(userroleid) NOT NULL, 
    password text NOT NULL
);
-- can a user have multiple cards? if so, scrap cardid for UserCards table with PK (userid,cardid)

-- Cardtype: typeid, type name, fare modifier
CREATE TABLE CardTypes (
    cardtypeid serial PRIMARY KEY,
    typename text NOT NULL,
    faremodifier text DEFAULT '1' -- ideally a function operator
);

-- OpalCard: cardid, card type id, expiry, balance
CREATE TABLE OpalCards (
    cardid serial PRIMARY KEY,
    cardtypeid REFERENCES CardTypes(cardtypeid) NOT NULL,
    userid int REFERENCES Users(userid) NOT NULL,
    expiry date,
    balance decimal NOT NULL
);


-- Limit: cardid, card type id, expiry, balance, cap_limit
CREATE TABLE CardLimit (
    cardid serial PRIMARY KEY,
    cardtypeid REFERENCES CardTypes(cardtypeid) NOT NULL,
    userid int REFERENCES Users(userid) NOT NULL,
    expiry date,
    balance decimal NOT NULL,
    cap_limit decimal
);
-- StationType: stationtypeid, typename
CREATE TABLE StationTypes (
    stationtypeid serial PRIMARY KEY,
    stationtypename text NOT NULL
);

-- Station: stationid, station name, stationtype, lat, long, (lines here or a routes table?)
CREATE TABLE Stations (
    stationid serial PRIMARY KEY,
    stationname varchar(250) NOT NULL,
    stationtypeid bigint REFERENCES StationTypes(stationtypeid) NOT NULL,
    latitude float,
    longitude float

);

-- Trips: tripid, userid, traveldate, entrystationid, exitstationid,tripstarttime
-- should tripstarttime and travel data be combined?
CREATE TABLE Trips (
    tripid serial PRIMARY KEY,
    cardid bigint REFERENCES OpalCards(cardid) ON DELETE CASCADE NOT NULL ,
    traveldate date NOT NULL,
    entrystationid bigint REFERENCES Stations(stationid) NOT NULL,
    exitstationid bigint REFERENCES Stations(stationid) NOT NULL,
    tripstarttime time
);

-- Travel times: start stationaid, end stationid, seconds/minutes?, minhops 
CREATE TABLE TravelTimes (
    startstationid bigint REFERENCES Stations(stationid) NOT NULL,
    endstationid bigint REFERENCES Stations(stationid) NOT NULL,
    expectedtraveltimeSeconds bigint NOT NULL,
    stopsTraversed bigint,
    triplegs int,
    coordinatemaplen bigint,
    CONSTRAINT traveltimes_pk PRIMARY KEY (startstationid, endstationid)
);


SET SCHEMA 'opaltravel';

-- assuming that schema.sql has been run and that all data has been dropped
-- test data to see if our code works

-- UserRoles: userroleid, rolename, isAdmin, (privilegeFlags?) 
INSERT INTO UserRoles(rolename, isAdmin) VALUES ('Traveler', false);
INSERT INTO UserRoles(rolename, isAdmin) VALUES ('Employee', false);
INSERT INTO UserRoles(rolename, isAdmin) VALUES ('Admin', true);
INSERT INTO UserRoles(rolename, isAdmin) VALUES ('Route Designer', true);

-- Cardtype: typeid, type name, fare modifier
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Adult','* 1');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Child/Youth','* 0.5');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Concession','* 0.5');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Employee','* 0');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Free Travel','* 0');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('School Student','* 0');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Senior/Pensioner','* 0 + 2.5');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Sgl Trip Rail Adult','* 1');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Sgl Trip Rail Child/Youth','* 0.5');
INSERT INTO CardTypes(typename, faremodifier) VALUES ('Day Pass without SAF','* 0 + 25');

-- StationTypes: stationtypeid, typename
INSERT INTO StationTypes(stationtypename) VALUES ('Train');
INSERT INTO StationTypes(stationtypename) VALUES ('Metro');
INSERT INTO StationTypes(stationtypename) VALUES ('Bus');
INSERT INTO StationTypes(stationtypename) VALUES ('Ferry');
INSERT INTO StationTypes(stationtypename) VALUES ('Light Rail');

-- Users: userid, cardid, firstname, lastname, preferredname, userroleid, password
INSERT INTO Users(firstname, lastname, userroleid, password) VALUES ('Bob', 'Sanderson', 1, 'brisket');
INSERT INTO Users(firstname, lastname, userroleid, password) VALUES ('Darren', 'Erikson', 1, 'brulee');
INSERT INTO Users(firstname, lastname, userroleid, password) VALUES ('Helene', 'Yung', 1, 'cake');
INSERT INTO Users(firstname, lastname, userroleid, password) VALUES ('Chirri', 'Parsons', 3, 'sherbert');


-- OpalCard: cardid, userid, cardtypeid, expiry, balance
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (1,1,now()+ interval '1 year',100, 25);
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (2,1,now()+ interval '1 year',20, 50);
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (3,2,now()+ interval '1 year',30, 20);
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (1,2,now()+ interval '1 year',500, 25);
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (4,3,now()+ interval '1 year',6,30);
INSERT INTO OpalCards(cardtypeid, userid, expiry, balance, cap_limit) VALUES (7,3,now()+ interval '1 year', 4, 40);



-- Station: stationid, station name, stationtype, lat, long, (lines here or a routes table?)
INSERT INTO Stations(stationname, stationtypeid) VALUES ('Strathfield', 1);
INSERT INTO Stations(stationname, stationtypeid) VALUES ('Redfern', 1);
INSERT INTO Stations(stationname, stationtypeid) VALUES ('Central', 1);
INSERT INTO Stations(stationname, stationtypeid) VALUES ('Central Chalmers Street', 2);
INSERT INTO Stations(stationname, stationtypeid) VALUES ('Circular Quay', 2);

-- Trips: tripid, userid, traveldate, entrystationid, exitstationid, tripstarttime
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/02/19',1,2,'10:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/02/26',1,2,'10:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/03/03',1,2,'10:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/03/10',1,2,'10:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/02/19',2,1,'19:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/02/26',2,1,'19:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/03/03',2,1,'19:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/03/10',2,1,'19:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (3,'2023/02/19',1,2,'7:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (3,'2023/03/19',1,2,'7:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (3,'2023/04/19',1,2,'7:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (3,'2023/05/19',1,2,'7:00:00');
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (3,'2023/06/19',1,2,'7:00:00');
-- logically invalid trip -- going from train to metro without tapping off
INSERT INTO Trips(cardid, traveldate, entrystationid, exitstationid,tripstarttime) VALUES (1,'2023/04/10',1,4,'11:00:00');

-- Travel times: start stationaid, end stationid, seconds/minutes?, minhops 
INSERT INTO TravelTimes(startstationid, endstationid, expectedtraveltimeSeconds, stopsTraversed, triplegs, coordinatemaplen) VALUES (1,2,780,3,1,15);
INSERT INTO TravelTimes(startstationid, endstationid, expectedtraveltimeSeconds, stopsTraversed, triplegs, coordinatemaplen) VALUES (2,3,180,1,1,4);
INSERT INTO TravelTimes(startstationid, endstationid, expectedtraveltimeSeconds, stopsTraversed, triplegs, coordinatemaplen) VALUES (1,3,900,4,1,19);
