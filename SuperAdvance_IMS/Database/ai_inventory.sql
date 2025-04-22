-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 22, 2025 at 04:43 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ai_inventory`
--

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `CustomerID` int(11) NOT NULL,
  `CNNameID` int(11) DEFAULT NULL,
  `CustomerAddressID` int(11) DEFAULT NULL,
  `C_Email` varchar(100) DEFAULT NULL,
  `C_Mobile` int(11) DEFAULT NULL,
  `C_Mobile2` int(11) DEFAULT NULL,
  `C_district` varchar(255) DEFAULT NULL,
  `C_status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customeraddress`
--

CREATE TABLE `customeraddress` (
  `CustomerAddressID` int(11) NOT NULL,
  `CA_Street` varchar(100) DEFAULT NULL,
  `CA_Barangay` varchar(100) DEFAULT NULL,
  `CA_District` varchar(100) DEFAULT NULL,
  `CA_City` varchar(10) DEFAULT NULL,
  `CA_Province` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customername`
--

CREATE TABLE `customername` (
  `CNNameID` int(11) NOT NULL,
  `CN_FirstName` varchar(100) DEFAULT NULL,
  `CN_LastName` varchar(100) DEFAULT NULL,
  `CN_MiddleName` varchar(100) DEFAULT NULL,
  `CN_Suffix` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `ItemID` int(11) NOT NULL,
  `I_LegacyCode` varchar(255) DEFAULT NULL,
  `I_Name` varchar(255) DEFAULT NULL,
  `I_Discount` decimal(10,2) DEFAULT NULL,
  `I_UnitPrice` decimal(10,2) DEFAULT NULL,
  `I_Image` longblob DEFAULT NULL,
  `I_Status` varchar(255) DEFAULT NULL,
  `I_Stock` int(11) DEFAULT NULL,
  `I_Description` text DEFAULT NULL,
  `I_QRCode` longblob DEFAULT NULL,
  `I_QRPath` int(11) NOT NULL,
  `I_LastUpdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `I_Suggestion` text DEFAULT NULL,
  `I_SuggestedPrice` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

CREATE TABLE `purchase` (
  `purchaseID` int(11) NOT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `P_Date` date DEFAULT NULL,
  `P_Quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sale`
--

CREATE TABLE `sale` (
  `saleID` int(11) NOT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL,
  `S_Date` date DEFAULT NULL,
  `S_Quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userID` int(11) NOT NULL,
  `fullName` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendor`
--

CREATE TABLE `vendor` (
  `VendorID` int(11) NOT NULL,
  `VNameID` int(11) DEFAULT NULL,
  `VendorAddressID` int(11) DEFAULT NULL,
  `V_Email` varchar(100) DEFAULT NULL,
  `V_Mobile` int(11) DEFAULT NULL,
  `V_Mobile2` int(11) DEFAULT NULL,
  `V_district` varchar(255) DEFAULT NULL,
  `V_status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendoraddress`
--

CREATE TABLE `vendoraddress` (
  `VendorAddressID` int(11) NOT NULL,
  `VA_Street` varchar(100) DEFAULT NULL,
  `VA_Barangay` varchar(100) DEFAULT NULL,
  `VA_District` varchar(100) DEFAULT NULL,
  `VA_City` varchar(10) DEFAULT NULL,
  `VA_Province` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendorname`
--

CREATE TABLE `vendorname` (
  `VNameID` int(11) NOT NULL,
  `VN_FirstName` varchar(100) DEFAULT NULL,
  `VN_LastName` varchar(100) DEFAULT NULL,
  `VN_MiddleName` varchar(100) DEFAULT NULL,
  `VN_Suffix` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`CustomerID`),
  ADD KEY `CNNameID` (`CNNameID`),
  ADD KEY `CustomerAddressID` (`CustomerAddressID`);

--
-- Indexes for table `customeraddress`
--
ALTER TABLE `customeraddress`
  ADD PRIMARY KEY (`CustomerAddressID`);

--
-- Indexes for table `customername`
--
ALTER TABLE `customername`
  ADD PRIMARY KEY (`CNNameID`);

--
-- Indexes for table `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`ItemID`);

--
-- Indexes for table `purchase`
--
ALTER TABLE `purchase`
  ADD PRIMARY KEY (`purchaseID`),
  ADD KEY `ItemID` (`ItemID`),
  ADD KEY `VendorID` (`VendorID`);

--
-- Indexes for table `sale`
--
ALTER TABLE `sale`
  ADD PRIMARY KEY (`saleID`),
  ADD KEY `ItemID` (`ItemID`),
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`userID`);

--
-- Indexes for table `vendor`
--
ALTER TABLE `vendor`
  ADD PRIMARY KEY (`VendorID`),
  ADD KEY `VNameID` (`VNameID`),
  ADD KEY `VendorAddressID` (`VendorAddressID`);

--
-- Indexes for table `vendoraddress`
--
ALTER TABLE `vendoraddress`
  ADD PRIMARY KEY (`VendorAddressID`);

--
-- Indexes for table `vendorname`
--
ALTER TABLE `vendorname`
  ADD PRIMARY KEY (`VNameID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customeraddress`
--
ALTER TABLE `customeraddress`
  MODIFY `CustomerAddressID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customername`
--
ALTER TABLE `customername`
  MODIFY `CNNameID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `item`
--
ALTER TABLE `item`
  MODIFY `ItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=135;

--
-- AUTO_INCREMENT for table `purchase`
--
ALTER TABLE `purchase`
  MODIFY `purchaseID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sale`
--
ALTER TABLE `sale`
  MODIFY `saleID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendor`
--
ALTER TABLE `vendor`
  MODIFY `VendorID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendoraddress`
--
ALTER TABLE `vendoraddress`
  MODIFY `VendorAddressID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendorname`
--
ALTER TABLE `vendorname`
  MODIFY `VNameID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customer`
--
ALTER TABLE `customer`
  ADD CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`CNNameID`) REFERENCES `customername` (`CNNameID`),
  ADD CONSTRAINT `customer_ibfk_2` FOREIGN KEY (`CustomerAddressID`) REFERENCES `customeraddress` (`CustomerAddressID`);

--
-- Constraints for table `purchase`
--
ALTER TABLE `purchase`
  ADD CONSTRAINT `purchase_ibfk_1` FOREIGN KEY (`ItemID`) REFERENCES `item` (`ItemID`),
  ADD CONSTRAINT `purchase_ibfk_2` FOREIGN KEY (`VendorID`) REFERENCES `vendor` (`VendorID`);

--
-- Constraints for table `sale`
--
ALTER TABLE `sale`
  ADD CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`ItemID`) REFERENCES `item` (`ItemID`),
  ADD CONSTRAINT `sale_ibfk_2` FOREIGN KEY (`customerID`) REFERENCES `customer` (`CustomerID`);

--
-- Constraints for table `vendor`
--
ALTER TABLE `vendor`
  ADD CONSTRAINT `vendor_ibfk_1` FOREIGN KEY (`VNameID`) REFERENCES `vendorname` (`VNameID`),
  ADD CONSTRAINT `vendor_ibfk_2` FOREIGN KEY (`VendorAddressID`) REFERENCES `vendoraddress` (`VendorAddressID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
