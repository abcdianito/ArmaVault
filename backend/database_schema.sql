-- ============================================================
-- Firearms Model Database
-- Midterm Exam: Mobile App + Custom REST API + External API
-- ============================================================

CREATE DATABASE IF NOT EXISTS firearms_db;
USE firearms_db;

CREATE TABLE IF NOT EXISTS firearms (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(100) NOT NULL,
    manufacturer      VARCHAR(100) NOT NULL,
    country_of_origin VARCHAR(100) NOT NULL,   -- used to query the REST Countries API
    firearm_type      VARCHAR(50)  NOT NULL,   -- Pistol, Rifle, Shotgun, SMG, Sniper Rifle...
    caliber           VARCHAR(50)  NOT NULL,
    year_introduced   INT,
    weight_kg         DECIMAL(5,2),
    barrel_length_cm  DECIMAL(6,2),
    magazine_capacity INT,
    description       TEXT,
    image_url         VARCHAR(255),
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Seed data so the app has something to show on first run
INSERT INTO firearms
(name, manufacturer, country_of_origin, firearm_type, caliber, year_introduced, weight_kg, barrel_length_cm, magazine_capacity, description, image_url)
VALUES
('AK-47', 'Kalashnikov Concern', 'Russia', 'Assault Rifle', '7.62x39mm', 1949, 4.30, 41.5, 30,
 'Gas-operated, selective-fire assault rifle known for its reliability and widespread global use.', NULL),
('M1911', 'Colt', 'United States', 'Pistol', '.45 ACP', 1911, 1.10, 12.7, 7,
 'Single-action, semi-automatic, recoil-operated handgun long used by the US military.', NULL),
('Glock 17', 'Glock', 'Austria', 'Pistol', '9x19mm', 1982, 0.62, 11.4, 17,
 'Polymer-framed, striker-fired semi-automatic pistol widely used by law enforcement.', NULL),
('Remington 870', 'Remington Arms', 'United States', 'Shotgun', '12 Gauge', 1950, 3.20, 71.0, 6,
 'Pump-action shotgun known for durability, used for hunting, sport, and defense.', NULL),
('Heckler & Koch MP5', 'Heckler & Koch', 'Germany', 'Submachine Gun', '9x19mm', 1966, 2.90, 22.5, 30,
 'Roller-delayed blowback submachine gun favored by special forces and police units.', NULL);
