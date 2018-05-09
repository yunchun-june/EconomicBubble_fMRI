clear all;
close all;
clc;
addpath('./Functions');
%Screen('Preference', 'SkipSyncTests', 1);

try

    %===== Parameters =====%
    initialCash         = 10000;
    initialStock        = 10;
    initialStockPrice   = 100;
    
    sizeOfBlock         = 1;
    totalTrials         = 1;
    
    resultTime          =10;
    gaptime             =2;  %supposed to be 2~6 sec gitter
    decideTime          =6;
    fixationTime        =2;  %supposed to be 2~6 sec gitter
    
    %===== Constants =====%
    MARKET_BASELINE     = 1;
    MARKET_BUBBLE       = 2;
    MARKET_BURST        = 3;
    TRUE                = 1;
    FALSE               = 0;
    
    %===== IP Config for local testing ===%
    inputRule = input('Enter rule(1: fMRI 2:behavioral): ','s');
    myID      = input('Enter your ID:','s');
    oppID     = input('Enter your opp ID:','s');
    assert(strcmp(inputRule,'1') || strcmp(inputRule,'2'))
    if strcmp(inputRule,'1') rule = 'player1'; end
    if strcmp(inputRule,'2') rule = 'player2'; end

    %myIP    = '192.168.1.102';
    %oppIP   = '192.168.1.104';
    myIP    ='localhost';
    oppIP    ='localhost';
    if strcmp(rule,'player1')
        myPort  = 5656;
        oppPort = 7878;
        displayerOn = TRUE;
        autoMode = FALSE;
    else
        myPort  = 7878;
        oppPort = 5656;
        displayerOn = FALSE;
        autoMode = TRUE;
    end
    
    %===== Inputs =====%

    fprintf('---Starting Experiment---\n');
    %myID                = input('your ID: ','s');
    %oppID               = input('Opponent ID: ','s');
    %displayerOn         = FALSE;
    screenID            = max(Screen('Screens'));
    
    %===== Initialize Componets =====%
    if strcmp(rule,'player1') keyboard    = keyboardHandler('fMRI'); end
    if strcmp(rule,'player2') keyboard    = keyboardHandler('behavioral'); end
    displayer   = displayer(max(Screen('Screens')),displayerOn,decideTime);
    parser      = parser();
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish(myID,oppID);
    ListenChar(2);
    HideCursor();
    
    %===== Open Screen =====% 
    fprintf('Start after 10 seconds\n');
    %WaitSecs(10);
    displayer.openScreen();
    
    %%%%%%%%%%%%%%%%%%%%  Start of real experiment %%%%%%%%%%%%%%%%%%%%
    
    %initialize components
    market      = market(MARKET_BASELINE,initialStockPrice);
    me          = player(initialCash,initialStock);
    opp         = player(initialCash,initialStock);
    data        = dataHandler(myID,oppID,rule,totalTrials);
    
    triggerZero = -1;
    for trial = 1:totalTrials
        
        %===== initializing block =====%
        
        if mod(trial,sizeOfBlock) == 1
            if strcmp(rule,'player1')
                displayer.writeMessage('Start of block','Wait for instructions');
                fprintf('Waiting for trigger...\n');
                triggerZero = keyboard.waitTrigger();
                fprintf('Trigger received, starting block.\n');
                displayer.blackScreen();
                WaitSecs(1);
            end
            
            if strcmp(rule,'player2')
                triggerZero = GetSecs();
            end

            displayer.writeMessage('Press confirm to start.','');
            fprintf('Waiting for subject to press confirm.\n');
            keyboard.waitConfirmPress();
            fprintf('Subject started the program.\n');
            displayer.blackScreen();
            WaitSecs(1);
        end
        
        if(trial == 21) market.setCondition(MARKET_BUBBLE); end
        if(trial == 61) market.setCondition(MARKET_BURST);end

        %=========== Setting Up Trials ==============%
        
        %Syncing
        if mod(trial,sizeOfBlock) == 1
            displayer.writeMessage('Waiting for Opponent','');
            cnt.syncTrial(trial);
            displayer.blackScreen();
        else
            cnt.syncTrial(trial);
        end
        
        % Update condition based on last decision
        data.updateCondition(market,me,opp,trial);
        statusData = data.getStatusData(trial);
               
        %=========== Fixation ==============%
        displayer.fixation(fixationTime);
       
        %========== Show Status and Make Decision ===============%

        data.logStatus(trial);
        deadline = GetSecs()+resultTime+decideTime;
        startTime = GetSecs() - triggerZero;
        decisionMade = FALSE;
        showHiddenInfo = FALSE;
        
        %response to get
        myRes.decision = 'no trade';
        myRes.events = cell(0,2);
        myRes.startOfTrial = startTime;
        
        for remaining = resultTime+decideTime:-1:1
            endOfThisSecond = deadline - remaining;
            while GetSecs() < endOfThisSecond
                if ~decisionMade
                    
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,FALSE);
                    
                    %===Getting Response===%
                    
                    %Auto Mode
                    if autoMode == TRUE
                        WaitSecs(0.5);
                        keyNameList = {'buy', 'no trade', 'sell', 'see','unsee'};
                        keyName = keyNameList{randi(5)};
                        timing = GetSecs();
                    end
                    
                    %Manual Mode
                    if autoMode == FALSE
                        [keyName,timing] = keyboard.getResponse(endOfThisSecond);
                    end
                    
                    %===Processing Response (seeing result)===%
                    
                    if remaining > decideTime && ~strcmp(keyName,'na')
                        myRes.events{end+1,1} = keyName;
                        myRes.events{end,2} = num2str(timing-triggerZero);
                        fprintf('%s %s\n',keyName,num2str(timing-triggerZero));  
                        
                        if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                        end
                        
                        if strcmp(keyName,'see')
                            showHiddenInfo = TRUE;
                        end
                        
                        if strcmp(keyName,'unsee')
                            showHiddenInfo = FALSE;
                        end
                    end
                    
                    %===Processing Response (making decision)===%
                    
                    if remaining <= decideTime && ~strcmp(keyName,'na')
                        myRes.events{end+1,1} = keyName;
                        myRes.events{end,2} = num2str(timing-triggerZero);
                        fprintf('%s %s\n',keyName,num2str(timing-triggerZero));
                        
                        if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            ShowCursor();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                        end
                        
                        if strcmp(keyName,'buy') && me.canBuy(market.stockPrice)
                            myRes.decision = 'buy';
                            decisionMade = TRUE;
                        end

                        if strcmp(keyName,'no trade')
                            myRes.decision = 'no trade';
                            decisionMade = TRUE;
                        end

                        if strcmp(keyName,'sell') && me.canSell()
                            myRes.decision = 'sell';
                            decisionMade = TRUE;
                        end

                        if strcmp(keyName,'see')
                            showHiddenInfo = TRUE;
                        end
                        
                        if strcmp(keyName,'unsee')
                            showHiddenInfo = FALSE;
                        end
                    end
                end %end of decision not made

                if decisionMade && GetSecs() < endOfThisSecond 
                    displayer.showDecision(statusData,myRes.decision,showHiddenInfo,remaining,TRUE);
                end
            end %while end of this second
        end
        
        displayer.blackScreen();

        if showHiddenInfo == TRUE
            myRes.events{end+1,1} = 'unsee';
            myRes.events{end,2} = num2str(GetSecs()-triggerZero);
        end
        
        if ~decisionMade
            myRes.decision = 'no trade';
        end
        
        fprintf('timesUp! decision: %s\n',myRes.decision);
        
        %========== Exchange and Save Data ===============%
        
        %Get opponent's response
        oppResRaw = cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
        oppRes = parser.strToRes(oppResRaw);
        
        %Save Data
        data.saveResponse(myRes,oppRes,trial);
        
        %Update market and player
        if(strcmp(myRes.decision,'buy'))   me.buyStock(market.stockPrice);end
        if(strcmp(myRes.decision,'sell'))  me.sellStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'buy'))  opp.buyStock(market.stockPrice);end
        if(strcmp(oppRes.decision,'sell')) opp.sellStock(market.stockPrice);end
        market.trade(myRes.decision,oppRes.decision);
    end
    
    % Update for last time and save to file
    data.updateCondition(market,me,opp,totalTrials+1);
    data.saveToFile();
    
    %show result on screen
    result = data.getResult();
    fprintf('Your Cash = %d\n',result.myCash);
    fprintf('Opponent Cash = %d\n',result.oppCash);
    
    if (result.myCash > result.oppCash)
        fprintf('[RESULT] you win\n');
    end
    if (result.myCash == result.oppCash)
        fprintf('[RESULT] draw\n');
    end
    if (result.myCash < result.oppCash)
        fprintf('[RESULT] you lose\n');
    end
    
    displayer.blackScreen();
    WaitSecs(1);
    
    displayer.writeMessage('End of experiment','Wait for instruction');
    keyboard.waitESCPress();

    displayer.closeScreen();
    ListenChar();
    ShowCursor();
    
    fprintf('----END OF EXPERIMENT----\n');
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
    ListenChar();
    ShowCursor();
end
