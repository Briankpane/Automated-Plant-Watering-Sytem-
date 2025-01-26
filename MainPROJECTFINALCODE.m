%Initialize the arduino connection
a = arduino('/dev/cu.usbserial-0001', 'Nano3')

% Assign pin variables
moistureSensorPin = 'A1'; % For soil moisture sensor
pumpPin = 'D2';           % To control the pump

% Set up the pump pin
configurePin(a, pumpPin, 'DigitalOutput');

% Initialize the pump state
pumpState = 0; % 0 = off, 1 = on

% Initialize arrays for plotting
timeArray = [];
moistureArray = [];

% Set up the live plot figure for moisture level wrt time
figure;
hold on;
plotHandle = plot(datetime('now'), 0, '-o');
xlabel('Time');
ylabel('Moisture Level (V)');
title('Soil Moisture Level Over Time');
grid on;
xtickformat('HH:mm:ss');

disp('Monitoring soil moisture levels...');

% Main loop
while true
    % Read the moisture level from the sensor
    moistureLevel = readVoltage(a, moistureSensorPin); 

    % Record time and moisture level
    currentTime = datetime('now');
    timeArray = [timeArray; currentTime]; 
    moistureArray = [moistureArray; moistureLevel]; 

    % Display the current moisture level
    disp(['Current moisture level: ', num2str(moistureLevel)]);

    % Automatic plant watering based on moisture level
    if moistureLevel >= 3.3 && pumpState == 0
        disp('Soil is dry. Activating pump...');
        writeDigitalPin(a, pumpPin, 1); % Turn on the pump
        pumpState = 1; % Update pump state
    elseif moistureLevel<=3.3 && moistureLevel>=2.8
        disp('The soil moisture is between dry and moist states');
    elseif moistureLevel < 2.8 && pumpState == 1
        disp('Soil is moist. Deactivating pump...');
        writeDigitalPin(a, pumpPin, 0); % Turn off the pump
        pumpState = 0; % Update pump state
    end

    % Update the plot with the new data
    updatePlot(plotHandle, timeArray, moistureArray);

%Record plots every second
    pause(1); 
end

% Function to update the plot with new data
function updatePlot(plotHandle, timeArray, moistureArray)
    % Update the plot data
    set(plotHandle, 'XData', timeArray, 'YData', moistureArray);
    drawnow; % Update the figure window 
end
