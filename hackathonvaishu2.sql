CREATE DATABASE SmartTrafficDB;
USE SmartTrafficDB;
CREATE TABLE TrafficJunctions (
    junction_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(255) NOT NULL,
    signal_status ENUM('Red', 'Green', 'Yellow') DEFAULT 'Red',
    congestion_level ENUM('Low', 'Medium', 'High') DEFAULT 'Low'
);
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    plate_number VARCHAR(15) UNIQUE NOT NULL,
    owner_name VARCHAR(100),
    vehicle_type ENUM('Car', 'Truck', 'Bus', 'Bike', 'Emergency'),
    registered_city VARCHAR(100)
);
CREATE TABLE TrafficViolations (
    violation_id INT PRIMARY KEY AUTO_INCREMENT,
    vehicle_id INT,
    violation_type ENUM('Speeding', 'Signal Jump', 'Wrong Lane', 'No Helmet', 'Other'),
    fine_amount DECIMAL(10,2) DEFAULT 500.00,
    date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    junction_id INT,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (junction_id) REFERENCES TrafficJunctions(junction_id) ON DELETE SET NULL
);
CREATE TABLE TrafficFlow (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    junction_id INT,
    vehicle_count INT DEFAULT 0,
    average_speed DECIMAL(5,2) DEFAULT 0.00,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (junction_id) REFERENCES TrafficJunctions(junction_id) ON DELETE CASCADE
);
CREATE TABLE TrafficOfficers (
    officer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    badge_number VARCHAR(20) UNIQUE NOT NULL,
    assigned_junction INT,
    contact VARCHAR(15),
    FOREIGN KEY (assigned_junction) REFERENCES TrafficJunctions(junction_id) ON DELETE SET NULL
);
-- Insert Traffic Junctions
INSERT INTO TrafficJunctions (location, signal_status, congestion_level) VALUES
('Downtown Signal 1', 'Green', 'Medium'),
('City Center Junction', 'Red', 'High'),
('Highway Exit 5', 'Yellow', 'Low');

-- Insert Vehicles
INSERT INTO Vehicles (plate_number, owner_name, vehicle_type, registered_city) VALUES
('KA-01-AB-1234', 'John Doe', 'Car', 'Bangalore'),
('MH-02-XY-5678', 'Alice Smith', 'Bike', 'Mumbai'),
('TN-09-PQ-4321', 'Raj Kumar', 'Truck', 'Chennai');

-- Insert Traffic Violations
INSERT INTO TrafficViolations (vehicle_id, violation_type, fine_amount, junction_id) VALUES
(1, 'Speeding', 1000, 2),
(2, 'Signal Jump', 500, 1);

-- Insert Traffic Flow Data
INSERT INTO TrafficFlow (junction_id, vehicle_count, average_speed) VALUES
(1, 250, 45.5),
(2, 500, 35.0);

-- Insert Traffic Officers
INSERT INTO TrafficOfficers (name, badge_number, assigned_junction, contact) VALUES
('Officer Mike', 'TX001', 1, '9876543210'),
('Officer Anita', 'TX002', 2, '9123456789');
DELIMITER //
CREATE PROCEDURE AdjustSignal(IN junctionId INT)
BEGIN
    DECLARE congestionStatus ENUM('Low', 'Medium', 'High');
    
    -- Get congestion level
    SELECT congestion_level INTO congestionStatus FROM TrafficJunctions WHERE junction_id = junctionId;
    
    -- Adjust signal based on congestion
    IF congestionStatus = 'High' THEN
        UPDATE TrafficJunctions SET signal_status = 'Red' WHERE junction_id = junctionId;
    ELSEIF congestionStatus = 'Medium' THEN
        UPDATE TrafficJunctions SET signal_status = 'Yellow' WHERE junction_id = junctionId;
    ELSE
        UPDATE TrafficJunctions SET signal_status = 'Green' WHERE junction_id = junctionId;
    END IF;
END //
DELIMITER ;
CALL AdjustSignal(2);
DELIMITER //
CREATE TRIGGER IncreaseFine
BEFORE INSERT ON TrafficViolations
FOR EACH ROW
BEGIN
    DECLARE repeatOffender INT;
    
    -- Check if the vehicle has past violations
    SELECT COUNT(*) INTO repeatOffender FROM TrafficViolations WHERE vehicle_id = NEW.vehicle_id;
    
    -- Increase fine if multiple violations
    IF repeatOffender > 1 THEN
        SET NEW.fine_amount = NEW.fine_amount * 2;
    END IF;
END //
DELIMITER ;
CREATE VIEW TrafficDashboard AS 
SELECT      
    TJ.location AS Junction,     
    TJ.signal_status AS `Signal`,  -- Fixed: Using backticks for reserved keyword  
    TJ.congestion_level AS Congestion,     
    COUNT(TV.violation_id) AS Total_Violations,     
    COUNT(TF.log_id) AS Traffic_Logs 
FROM TrafficJunctions TJ 
LEFT JOIN TrafficViolations TV ON TJ.junction_id = TV.junction_id 
LEFT JOIN TrafficFlow TF ON TJ.junction_id = TF.junction_id 
GROUP BY TJ.junction_id, TJ.location, TJ.signal_status, TJ.congestion_level;
SELECT * FROM TrafficDashboard;
SELECT * FROM TrafficViolations;
SELECT * FROM TrafficFlow;
