-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 15, 2025 at 05:28 PM
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
-- Database: `shop_inventory`
--

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customerID` int(11) NOT NULL,
  `fullName` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `mobile` int(11) NOT NULL,
  `phone2` int(11) DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `district` varchar(30) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Active',
  `createdOn` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customerID`, `fullName`, `email`, `mobile`, `phone2`, `address`, `address2`, `city`, `district`, `status`, `createdOn`) VALUES
(4, 'Bill Gates', 'bill@microsoft.com', 993737, 772484884, '45, Palo Alto House, Marine Drive', 'South Carolina', 'Microsoft', 'Kurunegala', 'Active', '2018-04-30 15:14:02'),
(14, 'Steve Jobs', 'sjobs@apple.com', 333829832, 0, '1st Floor, Apple House, ', 'Las Vegas Street', 'Las Vegas', 'Monaragala', 'Disabled', '2018-05-01 12:03:10'),
(18, 'Asitha Silva', 'asitha@gmail.com', 777987654, 0, 'No. 3, Radcliff Avenue, School Lane', 'Kalutara South', 'Kalutara', 'Kalutara', 'Active', '2018-05-02 09:52:28'),
(24, 'Sunil Perera', 'Sunil@gypsies.sound', 338393932, 413837293, '67/7, Perera Villa, Jayasekara Avenue', 'Mount Lavinia', 'Ratmalana', 'Colombo', 'Active', '2018-05-02 10:48:37'),
(25, 'Theresa May', 'may34@uk.gov.com', 329393903, 777833737, '12, Downing Street', 'London', 'London', 'Matale', 'Active', '2018-05-03 02:28:07'),
(26, 'Sachin Tendulkar', 'sachintendulkar@icc.com', 444958303, 84792838, '789-4, Apartment 3, ', 'Cric Complex', 'New Delhi', 'Puttalam', 'Active', '2018-05-03 02:28:38'),
(38, 'Nuwan Perara', 'nuwan@yahoo.com', 839378202, 0, 'Nuwan Villa, Lower Street,', 'North Mulativu', 'Mullaitivu', 'Mullaitivu', 'Active', '2018-05-05 11:17:49'),
(39, 'Amal Silverton', 'amals452@yahoo.com', 232345676, 0, 'Amal\'s House, Amal\'s Street,', 'Amal Road', 'Ambalangoda', 'Galle', 'Active', '2018-05-05 13:27:06'),
(40, 'Andrew Symonds', 'symonds@cricket.au.com', 123, 0, '23, Oak View Avenue', 'Western Australia', 'Melbourne', 'Colombo', 'Disabled', '2018-05-13 01:20:23'),
(41, 'Mark Taylor', '', 111, 0, '111', '', '', 'Colombo', 'Active', '2018-05-13 01:24:54'),
(42, 'Nelson Mandela', 'sjobs@apple.com', 333829832, 0, '1st Floor, Apple House, ', 'Las Vegas Street', 'Las Vegas', 'Kalutara', 'Disabled', '2018-05-13 02:39:41');

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `productID` int(11) NOT NULL,
  `itemNumber` varchar(255) NOT NULL,
  `itemName` varchar(255) NOT NULL,
  `discount` float NOT NULL DEFAULT 0,
  `stock` int(11) NOT NULL DEFAULT 0,
  `unitPrice` float NOT NULL DEFAULT 0,
  `imageURL` varchar(255) NOT NULL DEFAULT 'imageNotAvailable.jpg',
  `status` varchar(255) NOT NULL DEFAULT 'Active',
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `item`
--

INSERT INTO `item` (`productID`, `itemNumber`, `itemName`, `discount`, `stock`, `unitPrice`, `imageURL`, `status`, `description`) VALUES
(234, '2', 'Apple 13-inch MacBook Air', 0, 2, 500, '1747314560_images (2).jpg', 'Active', 'Apple 13-inch MacBook Air'),
(235, '3', 'Vivobook Go 12', 0, 12, 333, '1747314681_1747121331_images.jpg', 'Active', 'Vivobook Go 12\n'),
(236, '4', 'Logitech G331 Stereo Gami...', 0, 10, 3033, '1747314687_1747121458_Logitech.png', 'Active', 'Logitech G331 Stereo Gami...\n'),
(237, '5', 'Dell 65W USB-C Laptop Charger', 0, 6, 1200, '1747314694_1747121570_shopping (4).png', 'Active', ''),
(243, '2005', 'ACER 27 Nitro Monitor', 0, 50, 50.99, 'imageNotAvailable.jpg', 'Active', '4k 144hz'),
(244, '2006', 'Dell OptiPlex Laptop Charger 65W', 0, 10, 15.99, 'imageNotAvailable.jpg', 'Active', '65W'),
(245, '2007', 'Logitech G305', 0, 20, 10.99, 'imageNotAvailable.jpg', 'Active', '10 Million Clicks'),
(246, '2008', 'PHILIPS Webcam 2K', 0, 33, 40.99, 'imageNotAvailable.jpg', 'Active', '1080p'),
(247, '2009', 'ASUS Vivobook 15 Laptop', 0, 20, 150.99, 'imageNotAvailable.jpg', 'Active', 'Intel i9 14th gen'),
(248, '1010', 'Blackview Bv9300 Pro', 0, 10, 199.72, 'http://localhost/AIQRINVENTORY/SuperAdvance_IMS/Images/data/Blackview_Bv9300_Pro.png', 'Active', 'Blackview Bv9300 Pro');

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

CREATE TABLE `purchase` (
  `purchaseID` int(11) NOT NULL,
  `itemNumber` varchar(255) NOT NULL,
  `purchaseDate` date NOT NULL,
  `itemName` varchar(255) NOT NULL,
  `unitPrice` float NOT NULL DEFAULT 0,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `vendorName` varchar(255) NOT NULL DEFAULT 'Test Vendor',
  `vendorID` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `purchase`
--

INSERT INTO `purchase` (`purchaseID`, `itemNumber`, `purchaseDate`, `itemName`, `unitPrice`, `quantity`, `vendorName`, `vendorID`) VALUES
(40, '2', '2025-04-01', 'Apple 13-inch MacBook Air', 2341, 2, 'Arrow Electronics', 4),
(41, '4', '2025-04-01', 'Logitech G331 Stereo Gaming Headset', 1234, 3, 'Park Electronics', 3),
(43, '5', '2025-04-01', 'Dell 65W USB-C Laptop Charger', 35, 3, 'Park Electronics', 3),
(44, '5', '2025-04-02', 'Dell 65W USB-C Laptop Charger', 3000, 2, 'RS Components', 1),
(45, '5', '2025-04-02', 'Dell 65W USB-C Laptop Charger', 3000, 10, 'Digi-Key Electronics', 2),
(46, '4', '2025-04-02', 'Logitech G331 Stereo Gaming Headset', 1200, 4, 'Park Electronics', 3),
(47, '2', '2025-04-02', 'Apple 13-inch MacBook Air', 2, 1, 'Digi-Key Electronics', 2),
(50, '3', '2025-04-03', 'Vivobook Go 12', 1000, 5, 'Arrow Electronics', 4),
(51, '4', '2025-04-03', 'Logitech G331 Stereo Gaming Headset', 1121, 1, 'RS Components', 1),
(53, '5', '2018-05-24', 'Dell 65W USB-C Laptop Charger', 0, 3, 'RS Components', 1),
(54, '2', '2025-05-15', 'Apple 13-inch MacBook Air', 444, 3, 'RS Components', 1),
(63, '2', '2025-05-21', 'Apple 13-inch MacBook Air', 200, 2, 'RS Components', 1),
(64, '5', '2018-05-24', 'Dell 65W USB-C Laptop Charger', 1100, 3, 'Digi-Key Electronics', 2),
(65, '2007', '2018-05-24', 'Logitech G305', 8.5, 3, 'Digi-Key Electronics', 2),
(66, '3', '2025-05-02', 'Vivobook Go 12', 300, 1, 'Digi-Key Electronics', 2),
(67, '2', '2025-05-15', 'Apple 13-inch MacBook Air', 500, 2, 'RS Components', 1);

-- --------------------------------------------------------

--
-- Table structure for table `sale`
--

CREATE TABLE `sale` (
  `saleID` int(11) NOT NULL,
  `itemNumber` varchar(255) NOT NULL,
  `customerID` int(11) NOT NULL,
  `customerName` varchar(255) NOT NULL,
  `itemName` varchar(255) NOT NULL,
  `saleDate` date NOT NULL,
  `discount` float NOT NULL DEFAULT 0,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `unitPrice` float(10,0) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `sale`
--

INSERT INTO `sale` (`saleID`, `itemNumber`, `customerID`, `customerName`, `itemName`, `saleDate`, `discount`, `quantity`, `unitPrice`) VALUES
(1, '3', 4, 'Bill Gates', 'Vivobook Go 12', '2025-03-24', 5, 2, 1300),
(3, '4', 18, 'Asitha Silva', 'Logitech G331 Stereo Gaming Headset', '2025-03-24', 2, 1, 3409),
(4, '5', 25, 'Theresa May', 'Dell 65W USB-C Laptop Charger', '2025-03-24', 2, 1, 1200),
(6, '5', 14, 'Steve Jobs', 'Dell 65W USB-C Laptop Charger', '2025-03-24', 1.5, 1, 1650),
(7, '3', 4, 'Bill Gates', 'Vivobook Go 12', '2025-04-24', 0, 3, 1300),
(8, '2', 4, 'Bill Gates', 'Apple 13-inch MacBook Air', '2025-04-14', 2.1, 1, 2300),
(10, '5', 25, 'Theresa May', 'Dell 65W USB-C Laptop Charger', '2025-04-14', 2, 9, 1200),
(11, '4', 26, 'Sachin Tendulkar', 'Logitech G331 Stereo Gaming Headset', '2025-04-05', 1, 7, 1000),
(13, '3', 38, 'Nuwan Perara', 'Vivobook Go 12', '2025-04-24', 0, 0, 1300),
(15, '3', 38, 'Nuwan Perara', 'Vivobook Go 12', '2025-04-24', 1.5, 1, 1200),
(27, '4', 3, 'Asitha Silva', 'Logitech G331 Stereo Gaming Headset', '2025-05-15', 2, 2, 3409);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userID` int(11) NOT NULL,
  `fullName` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`userID`, `fullName`, `username`, `password`, `status`) VALUES
(5, 'Guest', 'guest', '81dc9bdb52d04dc20036dbd8313ed055', 'Active'),
(6, 'a', 'a', '0cc175b9c0f1b6a831c399e269772661', 'Active'),
(7, 'admin', 'admin', '21232f297a57a5a743894a0e4a801fc3', 'Active'),
(8, 'User', 'User', 'b9b57aae83585e17ede4570dcede353c', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `vendor`
--

CREATE TABLE `vendor` (
  `vendorID` int(11) NOT NULL,
  `fullName` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `mobile` int(11) NOT NULL,
  `phone2` int(11) DEFAULT NULL,
  `address` varchar(255) NOT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `district` varchar(30) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Active',
  `createdOn` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `vendor`
--

INSERT INTO `vendor` (`vendorID`, `fullName`, `email`, `mobile`, `phone2`, `address`, `address2`, `city`, `district`, `status`, `createdOn`) VALUES
(1, 'RS Components', '', 2343567, 0, '80, Ground Floor, ABC Shopping Complex', '46th Avenue', 'Kolpetty', 'Colombo', 'Active', '2018-05-05 05:48:44'),
(2, 'Digi-Key Electronics', 'sample@volvo.com', 99828282, 283730183, '123, A Road, B avenue', 'Pitipana', 'Nugegoda', 'Mannar', 'Disabled', '2018-05-05 06:12:02'),
(3, 'Park Electronics', '', 32323, 0, '34, Malwatta Road, Kottawa', 'Pannipitiya', 'Maharagama', 'Colombo', 'Active', '2018-05-05 06:28:33'),
(4, 'Arrow Electronics', 'vitton@vitton.usa.com', 323234938, 0, '45, Palmer Valley, 5th Crossing', 'Delaware', 'Palo Alto', 'Batticaloa', 'Active', '2018-05-05 06:29:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customerID`);

--
-- Indexes for table `item`
--
ALTER TABLE `item`
  ADD PRIMARY KEY (`productID`);

--
-- Indexes for table `purchase`
--
ALTER TABLE `purchase`
  ADD PRIMARY KEY (`purchaseID`);

--
-- Indexes for table `sale`
--
ALTER TABLE `sale`
  ADD PRIMARY KEY (`saleID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`userID`);

--
-- Indexes for table `vendor`
--
ALTER TABLE `vendor`
  ADD PRIMARY KEY (`vendorID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `item`
--
ALTER TABLE `item`
  MODIFY `productID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=249;

--
-- AUTO_INCREMENT for table `purchase`
--
ALTER TABLE `purchase`
  MODIFY `purchaseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `sale`
--
ALTER TABLE `sale`
  MODIFY `saleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vendor`
--
ALTER TABLE `vendor`
  MODIFY `vendorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
