% Knowledge Base
:- dynamic symptom/1.
:- dynamic issue/2.

% Existing issues and symptoms
issue(dead_battery, [no_start, dim_lights]).
issue(flat_tire, [car_leaning, flat_tire_visible]).
issue(overheating, [high_temperature_gauge, steam_from_hood]).
issue(brake_problem, [squeaking_noise, pedal_vibration]).

% Initializing predefined symptoms
initialize_symptoms :-
    forall(issue(_, Symptoms), 
        (forall(member(Symptom, Symptoms), 
            (symptom(Symptom) -> true; assertz(symptom(Symptom)))))).

% User Interface
start :-
    initialize_symptoms,  % Ensure all predefined symptoms are asserted
    write('Welcome to the Car Issue Diagnoser!'), nl,
    write('1. Diagnose Car Issue'), nl,
    write('2. Add Issue'), nl,
    write('3. Exit'), nl,
    read(Choice),
    handle_choice(Choice).

handle_choice(1) :-
    diagnose_interface,
    start.
handle_choice(2) :-
    add_issue_interface,
    start.
handle_choice(3) :-
    write('Goodbye!'), nl.

diagnose_interface :-
    write('Please answer the following questions:'), nl,
    findall(Symptom, symptom(Symptom), AllSymptoms),
    ask_symptoms(AllSymptoms, UserSymptoms),
    findall(Issue, diagnose(UserSymptoms, Issue), Issues),
    list_issues(Issues).

ask_symptoms([], []).
ask_symptoms([Symptom|Rest], UserSymptoms) :-
    format('Do you notice ~w? (yes/no) ', [Symptom]),
    read(Response),
    (Response == yes -> UserSymptoms = [Symptom | RestSymptoms];
                        UserSymptoms = RestSymptoms),
    ask_symptoms(Rest, RestSymptoms).

list_issues([]) :-
    write('No issues detected based on given symptoms.').
list_issues(Issues) :-
    write('Detected issues: '), nl,
    sort(Issues, UniqueIssues),  % Ensure unique issues
    forall(member(Issue, UniqueIssues), (write(Issue), nl, explanation(Issue))).

% Inference Engine
diagnose(UserSymptoms, Issue) :-
    issue(Issue, RequiredSymptoms),
    subset(RequiredSymptoms, UserSymptoms).

% Explanation Module
explanation(Issue) :-
    issue(Issue, Symptoms),
    format('The issue ~w is suggested because you reported the following symptoms: ~w.', [Issue, Symptoms]), nl.

% Add Issue Interface
add_issue_interface :-
    write('Enter the name of the new issue: '), nl,
    read(IssueName),
    write('Enter the symptoms for this issue (end with "done"): '), nl,
    read_symptoms(Symptoms),
    assert_issue(IssueName, Symptoms),
    write('Issue added successfully!'), nl.

% Read Symptoms
read_symptoms(Symptoms) :-
    read(Symptom),
    (Symptom == done -> Symptoms = [];
     read_symptoms(RestSymptoms),
     Symptoms = [Symptom | RestSymptoms]).

% Assert Issue
assert_issue(IssueName, Symptoms) :-
    assertz(issue(IssueName, Symptoms)),
    forall(member(Symptom, Symptoms), 
        (symptom(Symptom) -> true; assertz(symptom(Symptom)))).

