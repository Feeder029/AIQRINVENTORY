-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 24, 2025 at 08:25 PM
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
  `C_status` varchar(255) DEFAULT NULL,
  `C_LegacyID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`CustomerID`, `CNNameID`, `CustomerAddressID`, `C_Email`, `C_Mobile`, `C_Mobile2`, `C_district`, `C_status`, `C_LegacyID`) VALUES
(23, 45, 23, 'bill@microsoft.com', 993737, 772484884, NULL, 'Active', 4),
(24, 46, 24, 'sjobs@apple.com', 333829832, 0, NULL, 'Disabled', 14),
(25, 47, 25, 'asitha@gmail.com', 777987654, 0, NULL, 'Active', 18),
(26, 48, 26, 'Sunil@gypsies.sound', 338393932, 413837293, NULL, 'Active', 24),
(27, 49, 27, 'may34@uk.gov.com', 329393903, 777833737, NULL, 'Active', 25),
(28, 50, 28, 'sachintendulkar@icc.com', 444958303, 84792838, NULL, 'Active', 26),
(29, 51, 29, 'nuwan@yahoo.com', 839378202, 0, NULL, 'Active', 38),
(30, 52, 30, 'amals452@yahoo.com', 232345676, 0, NULL, 'Active', 39),
(31, 53, 31, 'symonds@cricket.au.com', 123, 0, NULL, 'Disabled', 40),
(32, 54, 32, '', 111, 0, NULL, 'Active', 41),
(33, 55, 33, 'sjobs@apple.com', 333829832, 0, NULL, 'Disabled', 42);

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

--
-- Dumping data for table `customeraddress`
--

INSERT INTO `customeraddress` (`CustomerAddressID`, `CA_Street`, `CA_Barangay`, `CA_District`, `CA_City`, `CA_Province`) VALUES
(23, '45, Palo Alto House, Marine Drive', NULL, 'Kurunegala', 'Microsoft', NULL),
(24, '1st Floor, Apple House, ', NULL, 'Monaragala', 'Las Vegas', NULL),
(25, 'No. 3, Radcliff Avenue, School Lane', NULL, 'Kalutara', 'Kalutara', NULL),
(26, '67/7, Perera Villa, Jayasekara Avenue', NULL, 'Colombo', 'Ratmalana', NULL),
(27, '12, Downing Street', NULL, 'Matale', 'London', NULL),
(28, '789-4, Apartment 3, ', NULL, 'Puttalam', 'New Delhi', NULL),
(29, 'Nuwan Villa, Lower Street,', NULL, 'Mullaitivu', 'Mullaitivu', NULL),
(30, 'Amal\'s House, Amal\'s Street,', NULL, 'Galle', 'Ambalangod', NULL),
(31, '23, Oak View Avenue', NULL, 'Colombo', 'Melbourne', NULL),
(32, '111', NULL, 'Colombo', '', NULL),
(33, '1st Floor, Apple House, ', NULL, 'Kalutara', 'Las Vegas', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `customerlist`
-- (See below for the actual view)
--
CREATE TABLE `customerlist` (
`CustomerID` int(11)
,`CNNameID` int(11)
,`CustomerAddressID` int(11)
,`C_Email` varchar(100)
,`C_Mobile` int(11)
,`C_Mobile2` int(11)
,`C_district` varchar(255)
,`C_status` varchar(255)
,`C_LegacyID` int(11)
,`CA_Street` varchar(100)
,`CA_Barangay` varchar(100)
,`CA_District` varchar(100)
,`CA_City` varchar(10)
,`CA_Province` varchar(10)
,`CN_FirstName` varchar(100)
,`CN_LastName` varchar(100)
,`CN_MiddleName` varchar(100)
,`CN_Suffix` varchar(10)
,`C_LFullName` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `customername`
--

CREATE TABLE `customername` (
  `CNNameID` int(11) NOT NULL,
  `CN_FirstName` varchar(100) DEFAULT NULL,
  `CN_LastName` varchar(100) DEFAULT NULL,
  `CN_MiddleName` varchar(100) DEFAULT NULL,
  `CN_Suffix` varchar(10) DEFAULT NULL,
  `C_LFullName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customername`
--

INSERT INTO `customername` (`CNNameID`, `CN_FirstName`, `CN_LastName`, `CN_MiddleName`, `CN_Suffix`, `C_LFullName`) VALUES
(45, NULL, NULL, NULL, NULL, 'Bill Gates'),
(46, NULL, NULL, NULL, NULL, 'Steve Jobs'),
(47, NULL, NULL, NULL, NULL, 'Asitha Silva'),
(48, NULL, NULL, NULL, NULL, 'Sunil Perera'),
(49, NULL, NULL, NULL, NULL, 'Theresa May'),
(50, NULL, NULL, NULL, NULL, 'Sachin Tendulkar'),
(51, NULL, NULL, NULL, NULL, 'Nuwan Perara'),
(52, NULL, NULL, NULL, NULL, 'Amal Silverton'),
(53, NULL, NULL, NULL, NULL, 'Andrew Symonds'),
(54, NULL, NULL, NULL, NULL, 'Mark Taylo3'),
(55, NULL, NULL, NULL, NULL, 'Nelson Mandela');

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

--
-- Dumping data for table `item`
--

INSERT INTO `item` (`ItemID`, `I_LegacyCode`, `I_Name`, `I_Discount`, `I_UnitPrice`, `I_Image`, `I_Status`, `I_Stock`, `I_Description`, `I_QRCode`, `I_QRPath`, `I_LastUpdate`, `I_Suggestion`, `I_SuggestedPrice`) VALUES
(57, '34', 'First Bag', 0.00, 1500.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f312f313532353637303939395f312e706e67, 'Active', 28, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000022a49444154789ced5a418ae4300c2c298639263f98a7383feb37ed0fe2a7f4030692e3428216c971969d5d16cfc0749bb18a264d77ea50502892ca21412512d73201a7b253e1d46ab053e1d46ab053a1a0130148d341c046f99231b7a4b50afcada951142b909d49afbb7e0df6af34a6b506fcbda9db5942b26c2f42b7e25baeb7c6b4f64b0d7ffd33ae106c935e1e21809d8a4fbb45f11ef42938ec0f12c04ec587dd1ab53b6d80a40984f8e3206b57d29256762a0cc966bf09a0db3aa84583d08c238f848d69ed980a798705e6d63f6ef0b3b5b253a1a0790bf902e020c4d56acb06435dbf5ad2da3335e4af340ddabc7e1230be0560dc2189cebe45716942ab53713ee6c6f32128223beca715982cd7eebc3c5d2b774fc5d995d6925ba83388a203fcb8ab517b31949fad95bba7a2644b56476ad97a1553be6b96b95b4db895a9d923eb5b1611269de567ad2d6c2f9e1336462575866ef7b22bc77bd0c43080c822f996b4f64c459932ae4655b6e33274f8bed55cdf8aabc6efb618ebf0ae4347be6d83a1bbd50835d855ec13cda1bc22ab510b40ba2c4b235ad9a9f8f3ec3897557ad53dd97cd386e667c78d9e1de34a9e721bd30ed698d61a701f67c7348f922342cbe51f27a0028cdea9e1dd6f4b0791a6b780b81c0169d2a3e42f14c04ec5a7a9646515efd74e6ce1fc0305fc078cdea9f89d0e9e6161d9b7ca3b4f9e133698131a861ce89679c373c256f7ad1392cbca5ed3c8f099f002a31aec5438b51aec5438b51adc3df517d4735acd050391fb0000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(58, '35', 'School Bag', 0.00, 500.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f322f313532353638313131315f3636313533392e706e67, 'Active', 5, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000020249444154789ced9b516ac3300c867f2b7977a007d851d21bec4c3bd26e101f650718c48f85140d394e937514d4415353eb7f30adfb3dfc20e44872ea184a05d29280a164280c558b0c85a16a91a110b9ac16085dfe0ac465fb58925795e8a5d19e4523e08e5102e559aa8f26ed72615e35a2d746e39242fd9896b34bdb73beed614021d24075a1a16b983fba86f3f9b7bb81db22d48eb657df19b1732c09c6887b1820437177b4bc3c9d243ce1574a71495ea97a14db3a020da31fd765d94e35c8f074af543ddafe49217f72db7c7bb4013214f7e6563f57f039ad78c0ba64842db7f074147328e6e3d04f484d575e78db74b1450ba5a041daaafe2b9d8b0dcf038d63943d3ed92ca334b44f15856776ae3bbb4d8121edd71e063422155503ea27a9e0db7cfe5d62949e5bbb185088503b8aa5ca98c083844cea8d1c3cab320aae0931cb4b64e4431a6830e708b2450bc5cc32e26162e0dcca7138a5868bc3dbd4ba871b2043f19f39a14be56052ff799090c98f7e2cc62b558f62edb7ae1aace574948ed94ec232ef8e79586fb5a4dfcaf546415e0dc5e5ee18c0d931a7dbc835508f37a011a9a8aaee8e6749a0c2f27246695e15a25a509f061acdf2041b4bf67a535411ca8364948c0897f769763660a8f2ee18a9dff2231c62078477abe08b8b56981f4e0d1cfcb7dd46968a3afbd7020c558b0c85a16a91a13054ad3be6843fadbc1767d70ff6190000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(59, '36', 'Office Bag', 15.00, 1300.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f332f313532353730393932345f6f6666696365206261672e6a7067, 'Active', 10, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000023349444154789ced9b516a23310c867f29037d9c400e90a33837d8232d3d526f303eca1ea0603f16665091e54c4a61c15dd8c4c4fa1f9cb1f91e7e101acbf284048d8adc4a028eb2a370b459ec281c6d163b0a15554da04b26422422205f972f3d796d123f351a449500793d8b00b30e389455e9cc6b8bf8b9d15c53887e275882d954f3ad37afe3a2d3b7b9209f564dab15c8f730c08ee2dfd178dca83cd4ddeaee06fe2ec6e8e8547f67dd9d32409813282c75597af2ca8ea2488b40a2a3d61b7f3480b94471b392b033af183db7649f4b3cafba79edf9f6bf0db0a3f8214a97924c7ad40a49f7adf943334a9fb29ec17af2da247e6a3496da6216a9712bca2f024db57b186811637414f5fc3baf4048f5382c222b442b0d9174103b3b2f0ff7cac3a3b8752b6499579b5a57a386f11abfe5e15e79781416144d2b1b34cb4a5a59aa2dda83f2dceaab268c4790c4f30749d9ad30bf4ff67644a66ebcf2f0e854c61a91fc2214de36929036abea29a4d34a9d78e5e151ec75457de1c9f5fd6755c66d2f5b1eee958747f1a5ca28b58586e77a63f215118f167acaad220b9466990dfb259778b4d0dddd314a8b30ee4f5a6a782fa3dbbbe345fb4db5fd54db1856d0a317af2de2e746f3fef9851618afda8db78f336e375ddc8bd706f1206828372628e7e4726cdec873ab57942eda7e0fb2f772bd07dff1ddb1209f04f157d2c56d9278966ebcf2f0e8643fd176a843e96a688161538b54bdf8e7477be5e151f27f2dc0d166b1a370b459ec281c6dd60ffa849f5117310db99183dc0000000049454e44ae426082, 0, '2025-04-24 11:15:22', NULL, NULL),
(60, '37', 'Leather Bag', 2.00, 3409.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f342f313532353731303031305f6c656174686572206261672e6a7067, 'Active', 6, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000021b49444154789ced5a5b6ac4300c1c29867e26d003e428d92bf706f1517a8042fc59485091e2eca350703ed2351b0d6c1eebf9181013eb61121422722913702a3b154e2d063b154e2d063b150aca080012915de8a217c3a526ad45e097a60ea298346efd0cc47e868c68ec5fa94c6b09f8b5a9295b48c61480e133c05eb3dfead25a003e0bb5556f754f14f0271867a7865fef64b61aa60e82f41f02d8a9d81dad5677a70448ec0584760e347c005293563e3d35acb748766bcc5b3390de8580858e17c04ec5ce68c9f55d341d44ecbf29fbed6801ec54eca4d2256912a8e9a03aca92f7bc703318d7a1f5cc54ac2595965a6a26c130691aaf4f7975ced5d8f874adec542888baadd4b20c5e13430c5323885e6fd59ac1b7eab035c100896d5e832c412ad1caa7a762ed2de9f7cfcc94b72c35585ef52f61753961ec67b5904666ead45a8d10daaf70b51a2ad0caa7a706bbd2f0f9b605e501f64d3c54003b15fbbdf5ad05d6a4a1696642b210e534fe5001ec54ecdfb71addb2f24625a2e9a0c1160ce3d3b5f2e9a9904758829123b8a51f1ead5a67c7623961ecb483b1955f3e3bae858a9b8fecfb675d8d7b6f5d5d373e5d2b3b158fb363bab422ab9922e9090d2c7e2ea3da69a420753a3b9eb42fbf047df27319d552493b86b77319b679b9b7aa9d1d4343163bab892d8d5fc8fb84b550717f066d6b11e6018af709ab9f1dc37e7763e36b43830f11c04e85538bc14e85538bc14ec54b527f0061582302d7dfd23f0000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(61, '38', 'Travel Bag', 2.00, 1200.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f352f313532353730363033325f74726176656c206261672e6a7067, 'Active', 17, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000021349444154789ced5b518aeb300c1c29867ea6f00eb047496ef08eb4eccde2a3ec0de2cf85043d64bb69bbb0e065795b516b3ed238ccc7809034b65c123422722b13702a3b154e6d063b154e6d063b150aaa08fa1680484440ba7c9e2d696d023f357512c50ac8a2c19b4751f731e4af624c6b0bf8b9a9a9a610bdae3bc9722c73aa19d3da2f357c5a4b3c0f1b01c306a4df10c04ec54fa83bd572f828015f81d13b35d4df51bb53026892fa105d8a25adec5464a809243aeb6bd200a6a0b9b5174b684c2b7acf2db9eb5b25ad6abefd6f01ec547c934a73c928cda371437d60a74b9619d2ea5460fc20c4970d98561c813a49f9664c6bbf54940db09ac0fad0b49a64ab4b5907297be7e5e15ab97b6ab8be6627984f3080f4478a3bd49a2846b4b25351a01915f59c70d6e615cfb565ddeebcd88a56f44e9dde4f228b36af494b5f095e6e59d97998d28adefb1630e6e655032522d96f68cbf2be65cf65c891511a9e5bab5182e7d13214ad4ba0f2ece4badfba0be8f270addc3d15728fe20973c8b4fe5d875ce2d182b9d97141a493da785d8e9b7b42c3b3e3311b4375f09772986d3ccc686d013f37351dd72fb4f4bde9697cb99ce1fb2dd3d454cba12c7a3943b3cc73cbeaa49ff2ec78923d5039df4d67d0b498d0ead4f069762c711e36c4bfab68dc82c41731a395bba7e2f60eda61def568a39e6fe472e80ede0695fc5f0b706a33d8a9706a33d8a9706a33bee132fe01c16b22dae21087840000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(62, '39', 'Gym Bag', 0.00, 3000.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f362f313532353731303436335f67796d206261672e6a7067, 'Active', 0, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000022349444154789ced9b416edc300c453f690359dac01ca047f1dca047ead5aca3f40005ecbd0c16a4a449bbe8405d9988f8813881e62d3e40d0faa22624e854e25e1208940345a0dde2401168b73850a8a86a063d71117012d1531fa6a727af5de22f8d6ea23a00d9cf0f215a274d1f93ad8a33af3de2af8d9eb58588be65d4ba95a69bdd79ed108f81ca7eb38137e2771f8e896e3f6720adf719f8b7f8cd6763a18b4879f559cad824eb5f808864775e313a9a2cfb958e9a849ea7ed56578984cebc0e8ccef6fc1c3f49d29481d3d6c497570e14aada4ca7f5d14548eb45ede4656730475e4746677b4a5a41824540dbf16aa9f32148df63dff283e28ff3ef76d87138eb61b9d648e498a49c9df7dbbdf2f028cab862472b8a95074b6e65d4b05810bedb2b0f8fa2d6c2daea78ad2eda60bab62f12bde50fbd889e5a236d262b5429594d1ebebc0e9e32e83356e09c33922d9c8f4cdbf1c8e4c42b0f8fa26d4bf6c2b3f75fcb1b3ada90bded60126f42b8e9ade5d7dc7a6bca3a272c0d458d8003af3c3c3adb53ea4fd6f24cba3265da76abd694bd78e540f1f7dd71996594f396cd37963adf8517af5de241ee8e55f5c6c432212eaa775eecc46b8f788cbb63942c6fc3c2367e8fde728b26fd4a8606c37a306e77fe70e815a3a3f443137ca28f52a898c1bb425136aad788b0f491cd325e0d56b4dfee958747e7f2ab0c2f30d5c89ed61ae36dd5b23ceef7cac3a314ffb58040bbc58122d06e71a008b45bff91097f03fed01bce3af4784b0000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(63, '40', 'Handbag', 1.50, 1650.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f372f313532353731333236375f68616e646261672e6a7067, 'Active', 10, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000021449444154789ced9b416ee3300c453f19015dcac01ca047b16f56f466d6517a836859c00607a464b79345a12c26112afe459c286ff18180d2278590a051895b49c05176148e368b1d85a3cd6247a1a2aa00a2491732112dfa625a7af2da24fed5e82caaabbecd01b444d1f471b155e9cc6b8bf877a3f92ca1f849f694b5145d788c8106710b34142a6b0ef5875a9e62e007314647c3cde75257c87fb60719604771371a45aca2648d22b4c4ad1498886cdd79c5e868b2ec3701f4f6118ea881bd44c2cebc62f49d50cecf922690a4d74dd7a42fafec28545f757484f7bd969a355dde6f7582a27454f3f522d6749517e8b9555badda74c9fa74afec284c69dac99a2e799f76b2808144a1a40cafaddecead6c917d0b8458bfb17041ffdd003b8a3b51aa67d44bd9fa4a31cdd71ae8fbf23a321aca635e77124093600e9ba4c5d67577041dd1909fed951d8529696dd90cded2a176c7a563d649af9f5b3d6642c4ef71b08ee4cf09fdfa74afec28aa2c13ea40d70e2fbbdab29bae6306858ebc0e8b42fed5b17cb45ffa6b796df57a770c4b8265969b2d6ae816d993d726f12077c7e95567f05967b916354a30ecc9aba338c781b3cee03522da5cde6bab7f54e47ad1eb2e1d117ef88d49bfa89c97fcb4c4cfa3f37aa0811fc4181d0df51975bfcbf6ce061a7ad3b50448a27ebcb2a3b8b93bb66068a38db7af8eb92baf03a3e4ff5a80a3cd6247e168b3d85138daac3be6847f0159b3fa73330eea680000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(64, '41', 'Laptop Bag', 2.10, 2300.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f382f313532353735303638335f3636313533392e706e67, 'Active', 9, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000021649444154789ced9b416ac3301045ff8c0d5dda37e851ec1bf4482547ea0deca3e406f6b2e0306546521c520a6aa1b188e62f5a497e8b0f42d21f8990205333e79280a3ec281ccd163b0a47b3c58e4245512d887aebb6a0714dc363495eb3c44f8d0ea25a00913311066d4d686c540af39a237e6e744d4b687edd2053f719bab6ca4af35a2fdadef56938bf083dd0003b8abfa3f3eb27c904db090f31f0b318b5a36dfcdfe9e9b4ea09f66143cd66c35292577614a6d9b25f6fed46e87d0168c42544c2c2bca2f6b525fb80a60c00178aebedbf0db0a3c8975846d7046fb93d84f79bdcdec5af321dee95ab47114aaaa9dbb4e8da108a2e0b18dab5d98a081fed95ab4711e762f9fe61b265b5c412597cb6500cdae9b2da2f3496e67a66e909f6000319e21ca80294c6b58df7169632e65ee7686dc39ee8f784a5a0888942cf2dfba35bdf9e3776447c27c4e12852888867d4cd97900efddc2a105db508be06438d88720a95d7830c6488513b8adbda0aba09868d318d85a7145f5bc5ed84269bb2546fc5ae57c7a5be1d23040c9ba855afa5744f9c4af29a25aee4ed784a813e1e63fa945c96d71c711d6fc744fd85e4d4c77b79fbe6f556a96fc732bf2da041b435dae5fcd696e295ab47dbfb81e14cbaacaefdb54fef29fc2f06d851fc1aed34f58596d55be95efe610632c4a81d45caeda626955a2109ea35468a88e2091e87a3e4bf5a80a3d96247e168b6d851389aad5fa48c2f8c49381ea099019e0000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(65, '43', 'Sports Bag', 1.00, 1000.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f31302f313532353735363238395f73706f727473206261672e6a7067, 'Active', 92, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000020749444154789ced59cb6dc3300c7da27db7810c9051940d3a52d191ba813d4a36b08f011cb02025c74d7a510bd421223e048128bfc303087e44064621462a65024e25a7c2a9c520a7c2a9c520a7421032da74c228a7d3bc5e9f2c692d02bd3435b2600278e81684773da1d15b36a6b504f4dad4f916426818e82ec9d478db45400108b553db073bc88fc7b09b00722afeec2dc4cf5e5c0630e63d049053f16b6ac7cc433a2da964692664e6c59c56d41e5b634a7d8d54b00387381dc4bc06535aa97a6aabff77e3a76bc849b0635b5ac9a910a4fe4f1e589a13351d62d4b7569fbfc28ad69aa9ed7664f905e09aefe2904f6c442b554f457a004b5b8138e5b662ed3758eef2139987a76b25a7025b2728eed1a1539e65e0aed5202b5a517b6cf1a44693a22c859a9afa41e752c3d3b552f554e449a0b41551de56e219cd890f14766fc14c6c29b46e6d8e92ecc85eb70c526759961c1768cb9e2a583cb736b5d64b85c6cd6ae8f85d13e37a9756291e5b0633214b44a967e48b5630f5a0771996634ba14fadcd64f716eced8e79d21994942ced13cf328d32a5b50454c7ee3808f8a3d7b97c7694cf09ad6e23797c9b1022e70906034b6b452b554f6d7fdccc41c24a4ad62c1136f73ed5b5bb3b8e3ad5ed2e01e371d951400108b55391fabf8ce6d609dec6183e2734bc3b66605133cf0ebf2d90e95f049053e1d4629053e1d4629053f192d42f825d407c3164331a0000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(66, '45', 'First Aid Bag', 1.50, 1200.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f31312f313532353738373535315f666972737420616964206261672e6a7067, 'Active', 11, '', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba8000001fd49444154789ced5b516ac3300c7d9203fb746107f2aeb623ed06c9517a8041f259c8d090eda45dc7c065b41558ef23b1d3f7f140487a9629091a31712b13702a3b154e6d063b154e6d063b150aaa18406f4b7d00cbf6f9cd92d69ea91005527ecd61f71c4190e62017bf8e4fd7ca4e45c1b2a71082c8882fcaeb9c6f0f11d0006e2175451599f51545ec6bed8f3a5ced09f144928ef42801ec54dc4c8dda9934b7466d59b96f29446435a715bde7d654722980d27158297de46d6d5e7715c04ec58dd1927d2fc089643a045d892daddc3d159b47df0a5e529751b66a35ead61dbca168956ea541a9dfb61815435f28fc6cadec5414c41361d2b3959e89f3c94bde69282ec36719161d7c1aabad38b72cb2a495bba7e272b6541cbc22ae5a0e75aa919b9757425bd19a737b5a4b252c21cb0663a788470b56a285ed745ceca03eb2f338fb0df168c1526ea1faf65c04771baff06819ed5b289530eef3a61c3c8f960d2ae427ce95b09eb7346e9e5ba61c3cd55d5881e5009928086179d50cd3950daddc3d15bfee8ee365467925347e77bce840e338e85c9eea05b2cf32ac52d36ede8b83d7b83d54c0df60f44e1daef6dab2d672818cf84948e33a58d1cadd5387fa8e3a185cea467239ccab7a4d793f014ee5ffdc1d4bb68861a5747c5197316f8e919fad95bba792ff6b014e6d063b154e6d063b154e6dc60db38c6f8e1955fb352e6da70000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(67, '49', 'Hiking Bag', 1.50, 1200.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f31342f313532363239373634305f68696b696e67206261672e6a7067, 'Active', 6, 'This is a hiking bag. Ideal for long distance hikes. Light-weight and water proof.', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000022049444154789ced9b416ee3300c45bf6801b374801ea047716e30679d1b5847990314b096051470404a8ad34e5b288bd442c5bf4855e52d3e40d0fea210c76854a0561230940c85a1cd22436168b3c850885c91cf9bba0662dd3ef7e4b549f4a3d185451be0ce510a35b3a48f4977b933af2da29f8dc6da42e1343196ede2747bef37f4e3b54134121a4e1397e7df31063e147dbc3d30caebfceab06cb23ac4c017228c8efaf27796b7539437d886fca272cb1f94e5230d90a1b8170d9afd4e9a327cfe0070c991b033af18bdb778df08274879246568bf3dda00198a76b166f492e0350e4eacaf2c5e5157aaf570af343c8abd5a5838dd9cbcea51ab1cbad8aa856eaab5495136d998538e83a5d5ae155c0ff74ac3a3289d537b8b57a996d64d2a98a71a56adae5097e74df19774591d68886e0f5dd487d79151bf2f393c2738cc1b3bcc2f35b7475713233dc400198afbd1896b8379f0aae72d9d6a7082cde0bb432f5299326f7767c89350cec936d5ed32c1a737ff6ac050cd3584ac877ba5e151ec99f0f69c7c3d83c923d232612fa8d7cf1a29a6c4c14dc9c90a884f0998b76ebc92a1505d27189a2d98f536724edf67a045d4440d7577bcfcd53898f25c5ebfe8cd6b836810343c33ebdd499eeae67efb4e039f8b303aeaffdb893e71387bb8852f8ee5dac475e2958647fdfbbb63910c344a8dc26f4b19dd552be4da4cb9a3ca77f189bbf24ac3a3ce7eb500439b4586c2d06691a130b45977cc09ff01a52f28e843d14b250000000049454e44ae426082, 0, '2025-04-23 12:14:06', NULL, NULL),
(68, '50', 'Laptop Case', 0.00, 8000.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f32362f313734353435373636305f696d616765732e6a7067, 'Active', 44, 'Laptop Casing', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000022549444154789ced9b518ee3200c867f3b48fb48a439c01e25b9c19c756f108e320758091e2b51796542d2ce3cace84adba2c17e08907e0fbf64196c9392a0d102b79280a16c280c6d36361486361b1b0a35aae6402baefb1c48c7ebb527ad4dc6df1a5d442dea34fdd0d9a4d9c754de4a675a5b8cbf379ace10f21908f3755f9678eb4debb8a8fbb296403af8087a8e003614ffec2d02a60c249705e91902d8503c8c7a11d934b6443268f5fa3896bd69c5e86828b9df0cd09a34dccae3961d76a515a3ef8472ae05b890849f5967d297561e1ec59ea32fe786b744cddb23209bd71fe291df6f2fd7cac3a338bc753e623dad8e52ab165d62de4237de8a25a22691cd67947ce3ae3ab6d8ea2c83f719b46c17c212afa025ce90b09684fe3f0b6043f1a8b7c21c2148b3ce2721785197bd41c2fb5927f3abb5f2f0a8db87e597bac46777dfd0c055073a52437eb5561e1ec5ad6f7bf4724ff347a7d7ceadbed0256a61eccbb9553d28f2512be6ceb40e8cba633265d273abd6c4fb09a6e67f3bdb097b41219fadd6c97a6d52caaf7326b613a293d8a2bad2f67b6d440921bde59a22f6a1950dc5d7bb6375cf9ab497ab615513c39eb41a8adbddb1b6dfc35cfbf2cf13d060dc028d87cadd77191f76d3df2f2ada222c1f3ec9e62f54ee259f2ae02fc6181d7575f4256fd7fdef5dafb6ca257f726757a30bad86ba7da84e99b43ba8cb75cada27ccf7dfd3f0abb5f2f028d9bf166068b3b1a130b4d9d85018da6c0ff409ff00f4cb1a3d4d9a7e300000000049454e44ae426082, 0, '2025-04-24 11:15:22', NULL, NULL),
(69, '51', 'Bag Bag', 0.00, 8000.00, 0x687474703a2f2f6c6f63616c686f73742f41495152494e56454e544f52592f416476616e63655f494d532f646174612f6974656d5f696d616765732f32382f313734353435373636385f696d616765732e6a7067, 'Active', 50, 'efsdse', 0x89504e470d0a1a0a0000000d494844520000014a0000014a010000000053522ba80000020949444154789ced5b416ec3300ca395003d263fd853d29f0dfd59f394fe20390e68c04196b3763b0cee61ab508b87a1f378104050a6e42e119598a596090455828aa05643828aa05643820a452ae8ed13b0a6948efa23e3e8a9d62ac84b53272a16806774c43c769a3eba7c4a67b5d6405e9bba160ba5f7654b984cb76cbade5dad159036a83cbd5d515adf530af80582d6a9fdcf8369d9c079ecfeab00092a1ea60ee45deb9b580c46f2eaae56b44e9d73f61bb3b73aa6e39a3db7592474562b5aef84fcfafdd604797ffc770504551ea52633d3aa3e1a3e12e671d388b8e9e4d5efa1437cd45a0579652a2d090e5760ba1cec0603d60331bfc5bde5870a1b804d1e1d8ccb59d1885c3adaec7c7e7aadd23c15b6add0711818ae2614cff649d7181a164d507976add23c15b7dd92f9c80c967be2d291e741b50cb53c519945316fa9cb542893cc9287a75a5ba6e29bb7f6ad6e815e59716ff94b19d45861a27c3541136fbfc1186ac1c9749cd44709eb086a82c73cea91fd2176f0dea82c4990dcd7efa5ffdd523dbcd45a0569e3ed187997a15bddbcc6c8512376196edf8e4fc93aa1099557bb65761627b5364cc5dd746cd922dbca8452e4d01129c32975d6af6494d5469131bce5959ade2fbd3e771df66c113b78879d90f9deda3b6199894b4e8c79cbebdb714a63479ec6fdc54411def2424df15f0b086a3524a8086a3524a8086a351ec8849f3c143b8dc76fe5b70000000049454e44ae426082, 0, '2025-04-24 01:21:28', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

CREATE TABLE `purchase` (
  `purchaseID` int(11) NOT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `VendorID` int(11) DEFAULT NULL,
  `P_Date` date DEFAULT NULL,
  `P_Quantity` int(11) DEFAULT NULL,
  `P_LegacyID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchase`
--

INSERT INTO `purchase` (`purchaseID`, `ItemID`, `VendorID`, `P_Date`, `P_Quantity`, `P_LegacyID`) VALUES
(1, 57, 3, '2018-05-24', 10, 39),
(2, 58, 4, '2018-05-18', 2, 40),
(3, 60, 3, '2018-05-07', 3, 41),
(4, 57, 4, '2018-05-24', 12, 42),
(5, 61, 3, '2018-05-03', 3, 43),
(6, 61, 1, '2018-05-16', 2, 44),
(7, 61, 2, '2018-05-21', 10, 45),
(8, 60, 3, '2018-05-19', 4, 46),
(9, 58, 2, '2018-05-10', 1, 47),
(10, 57, 1, '2018-05-12', 9, 48),
(11, 67, 4, '2018-05-15', 5, 50),
(12, 66, 1, '2018-05-11', 1, 51),
(13, 57, 2, '2018-05-21', 2, 52);

-- --------------------------------------------------------

--
-- Stand-in structure for view `purchaselist`
-- (See below for the actual view)
--
CREATE TABLE `purchaselist` (
`purchaseID` int(11)
,`P_Date` date
,`P_Quantity` int(11)
,`P_LegacyID` int(11)
,`ItemID` int(11)
,`I_LegacyCode` varchar(255)
,`I_Name` varchar(255)
,`I_Discount` decimal(10,2)
,`I_UnitPrice` decimal(10,2)
,`I_Image` longblob
,`I_Status` varchar(255)
,`I_Stock` int(11)
,`I_Description` text
,`I_QRCode` longblob
,`I_QRPath` int(11)
,`I_LastUpdate` timestamp
,`I_Suggestion` text
,`I_SuggestedPrice` decimal(10,2)
,`VendorID` int(11)
,`VendorAddressID` int(11)
,`V_Email` varchar(100)
,`V_Mobile` int(11)
,`V_Mobile2` int(11)
,`V_district` varchar(255)
,`V_status` varchar(255)
,`V_LegacyID` int(11)
,`VNameID` int(11)
,`VN_FirstName` varchar(100)
,`VN_LastName` varchar(100)
,`VN_MiddleName` varchar(100)
,`VN_Suffix` varchar(10)
,`V_LFullName` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `sale`
--

CREATE TABLE `sale` (
  `saleID` int(11) NOT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `customerID` int(11) DEFAULT NULL,
  `S_Date` date DEFAULT NULL,
  `S_Quantity` int(11) DEFAULT NULL,
  `S_LegacyID` int(11) NOT NULL,
  `S_Discount` float NOT NULL,
  `S_UnitPrice` float(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sale`
--

INSERT INTO `sale` (`saleID`, `ItemID`, `customerID`, `S_Date`, `S_Quantity`, `S_LegacyID`, `S_Discount`, `S_UnitPrice`) VALUES
(1, 59, 23, '2018-05-24', 2, 1, 5, 1300),
(2, 57, 30, '2018-05-24', 111, 2, 0, 1500),
(3, 60, 25, '2018-05-24', 1, 3, 2, 3409),
(4, 61, 27, '2018-05-24', 1, 4, 2, 1200),
(5, 62, 26, '2018-05-24', 1, 5, 0, 3000),
(6, 63, 24, '2018-05-24', 1, 6, 1.5, 1650),
(7, 59, 23, '2018-05-24', 3, 7, 0, 1300),
(8, 64, 23, '2018-05-14', 1, 8, 2.1, 2300),
(9, 62, 28, '2018-05-14', 1, 9, 0, 3000),
(10, 61, 27, '2018-05-14', 9, 10, 2, 1200),
(11, 65, 28, '2018-04-05', 7, 11, 1, 1000),
(12, 57, 24, '2018-05-14', 2, 12, 0, 1500),
(13, 59, 30, '2018-05-24', 0, 13, 0, 1300),
(15, 67, 29, '2018-05-24', 1, 15, 1.5, 1200),
(16, 57, 24, '2018-05-24', 1, 16, 10, 1500),
(17, 60, 24, '2018-05-18', 1, 17, 2, 3409),
(18, 65, 30, '2018-05-17', 1, 14, 1, 1000),
(19, 68, 26, '2018-05-24', 6, 18, 3, 8000);

-- --------------------------------------------------------

--
-- Stand-in structure for view `salelist`
-- (See below for the actual view)
--
CREATE TABLE `salelist` (
`saleID` int(11)
,`S_Date` date
,`S_Quantity` int(11)
,`S_LegacyID` int(11)
,`ItemID` int(11)
,`S_Discount` float
,`S_UnitPrice` float(10,0)
,`I_LegacyCode` varchar(255)
,`I_Name` varchar(255)
,`I_Discount` decimal(10,2)
,`I_UnitPrice` decimal(10,2)
,`I_Image` longblob
,`I_Status` varchar(255)
,`I_Stock` int(11)
,`I_Description` text
,`I_QRCode` longblob
,`I_QRPath` int(11)
,`I_LastUpdate` timestamp
,`I_Suggestion` text
,`I_SuggestedPrice` decimal(10,2)
,`CustomerID` int(11)
,`CustomerAddressID` int(11)
,`C_Email` varchar(100)
,`C_Mobile` int(11)
,`C_Mobile2` int(11)
,`C_district` varchar(255)
,`C_status` varchar(255)
,`C_LegacyID` int(11)
,`CNNameID` int(11)
,`CN_FirstName` varchar(100)
,`CN_LastName` varchar(100)
,`CN_MiddleName` varchar(100)
,`CN_Suffix` varchar(10)
,`C_LFullName` varchar(100)
);

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
  `V_status` varchar(255) DEFAULT NULL,
  `V_LegacyID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vendor`
--

INSERT INTO `vendor` (`VendorID`, `VNameID`, `VendorAddressID`, `V_Email`, `V_Mobile`, `V_Mobile2`, `V_district`, `V_status`, `V_LegacyID`) VALUES
(1, 1, 1, '', 2343567, 0, NULL, 'Active', 1),
(2, 2, 2, 'sample@volvo.com', 99828282, 283730183, NULL, 'Disabled', 2),
(3, 3, 3, '', 32323, 0, NULL, 'Active', 3),
(4, 4, 4, 'vitton@vitton.usa.com', 323234938, 0, NULL, 'Active', 4),
(5, 5, 5, 'test@vendor.com', 43434, 47569937, NULL, 'Active', 6),
(6, 6, 6, '', 1111, 0, NULL, 'Active', 7),
(7, 7, 7, '', 191938930, 0, NULL, 'Active', 8),
(8, 8, 8, 'a@gmail.com', 999995, 98866767, NULL, 'Active', 9);

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

--
-- Dumping data for table `vendoraddress`
--

INSERT INTO `vendoraddress` (`VendorAddressID`, `VA_Street`, `VA_Barangay`, `VA_District`, `VA_City`, `VA_Province`) VALUES
(1, '80, Ground Floor, ABC Shopping Complex', NULL, 'Colombo', 'Kolpetty', NULL),
(2, '123, A Road, B avenue', NULL, 'Mannar', 'Nugegoda', NULL),
(3, '34, Malwatta Road, Kottawa', NULL, 'Colombo', 'Maharagama', NULL),
(4, '45, Palmer Valley, 5th Crossing', NULL, 'Batticaloa', 'Palo Alto', NULL),
(5, 'Test address', NULL, 'Trincomalee', 'Test City', NULL),
(6, 'Sea Road, Bambalapitiya', NULL, 'Colombo', '', NULL),
(7, '123, A Road, B avenue, ', NULL, 'Colombo', 'Colpetty', NULL),
(8, 'manila', NULL, 'Ampara', 'Manila Cit', NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vendorlist`
-- (See below for the actual view)
--
CREATE TABLE `vendorlist` (
`VendorID` int(11)
,`VNameID` int(11)
,`VendorAddressID` int(11)
,`V_Email` varchar(100)
,`V_Mobile` int(11)
,`V_Mobile2` int(11)
,`V_district` varchar(255)
,`V_status` varchar(255)
,`V_LegacyID` int(11)
,`VA_Street` varchar(100)
,`VA_Barangay` varchar(100)
,`VA_District` varchar(100)
,`VA_City` varchar(10)
,`VA_Province` varchar(10)
,`VN_FirstName` varchar(100)
,`VN_LastName` varchar(100)
,`VN_MiddleName` varchar(100)
,`VN_Suffix` varchar(10)
,`V_LFullName` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `vendorname`
--

CREATE TABLE `vendorname` (
  `VNameID` int(11) NOT NULL,
  `VN_FirstName` varchar(100) DEFAULT NULL,
  `VN_LastName` varchar(100) DEFAULT NULL,
  `VN_MiddleName` varchar(100) DEFAULT NULL,
  `VN_Suffix` varchar(10) DEFAULT NULL,
  `V_LFullName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vendorname`
--

INSERT INTO `vendorname` (`VNameID`, `VN_FirstName`, `VN_LastName`, `VN_MiddleName`, `VN_Suffix`, `V_LFullName`) VALUES
(1, NULL, NULL, NULL, NULL, 'ABC Company'),
(2, NULL, NULL, NULL, NULL, 'Sample Vendor 222'),
(3, NULL, NULL, NULL, NULL, 'Johnson and Johnsons Co.'),
(4, NULL, NULL, NULL, NULL, 'Louise Vitton Bag'),
(5, NULL, NULL, NULL, NULL, 'Test Vendor'),
(6, NULL, NULL, NULL, NULL, 'Bags Co. Exporters Ltd.'),
(7, NULL, NULL, NULL, NULL, 'New Bags Exporters'),
(8, NULL, NULL, NULL, NULL, 'A');

-- --------------------------------------------------------

--
-- Structure for view `customerlist`
--
DROP TABLE IF EXISTS `customerlist`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customerlist`  AS SELECT `a`.`CustomerID` AS `CustomerID`, `a`.`CNNameID` AS `CNNameID`, `a`.`CustomerAddressID` AS `CustomerAddressID`, `a`.`C_Email` AS `C_Email`, `a`.`C_Mobile` AS `C_Mobile`, `a`.`C_Mobile2` AS `C_Mobile2`, `a`.`C_district` AS `C_district`, `a`.`C_status` AS `C_status`, `a`.`C_LegacyID` AS `C_LegacyID`, `b`.`CA_Street` AS `CA_Street`, `b`.`CA_Barangay` AS `CA_Barangay`, `b`.`CA_District` AS `CA_District`, `b`.`CA_City` AS `CA_City`, `b`.`CA_Province` AS `CA_Province`, `c`.`CN_FirstName` AS `CN_FirstName`, `c`.`CN_LastName` AS `CN_LastName`, `c`.`CN_MiddleName` AS `CN_MiddleName`, `c`.`CN_Suffix` AS `CN_Suffix`, `c`.`C_LFullName` AS `C_LFullName` FROM ((`customer` `a` join `customeraddress` `b` on(`a`.`CustomerAddressID` = `b`.`CustomerAddressID`)) join `customername` `c` on(`a`.`CNNameID` = `c`.`CNNameID`)) ;

-- --------------------------------------------------------

--
-- Structure for view `purchaselist`
--
DROP TABLE IF EXISTS `purchaselist`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `purchaselist`  AS SELECT `a`.`purchaseID` AS `purchaseID`, `a`.`P_Date` AS `P_Date`, `a`.`P_Quantity` AS `P_Quantity`, `a`.`P_LegacyID` AS `P_LegacyID`, `b`.`ItemID` AS `ItemID`, `b`.`I_LegacyCode` AS `I_LegacyCode`, `b`.`I_Name` AS `I_Name`, `b`.`I_Discount` AS `I_Discount`, `b`.`I_UnitPrice` AS `I_UnitPrice`, `b`.`I_Image` AS `I_Image`, `b`.`I_Status` AS `I_Status`, `b`.`I_Stock` AS `I_Stock`, `b`.`I_Description` AS `I_Description`, `b`.`I_QRCode` AS `I_QRCode`, `b`.`I_QRPath` AS `I_QRPath`, `b`.`I_LastUpdate` AS `I_LastUpdate`, `b`.`I_Suggestion` AS `I_Suggestion`, `b`.`I_SuggestedPrice` AS `I_SuggestedPrice`, `c`.`VendorID` AS `VendorID`, `c`.`VendorAddressID` AS `VendorAddressID`, `c`.`V_Email` AS `V_Email`, `c`.`V_Mobile` AS `V_Mobile`, `c`.`V_Mobile2` AS `V_Mobile2`, `c`.`V_district` AS `V_district`, `c`.`V_status` AS `V_status`, `c`.`V_LegacyID` AS `V_LegacyID`, `d`.`VNameID` AS `VNameID`, `d`.`VN_FirstName` AS `VN_FirstName`, `d`.`VN_LastName` AS `VN_LastName`, `d`.`VN_MiddleName` AS `VN_MiddleName`, `d`.`VN_Suffix` AS `VN_Suffix`, `d`.`V_LFullName` AS `V_LFullName` FROM (((`purchase` `a` join `item` `b` on(`a`.`ItemID` = `b`.`ItemID`)) join `vendor` `c` on(`a`.`VendorID` = `c`.`VendorID`)) join `vendorname` `d` on(`c`.`VNameID` = `d`.`VNameID`)) ;

-- --------------------------------------------------------

--
-- Structure for view `salelist`
--
DROP TABLE IF EXISTS `salelist`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `salelist`  AS SELECT `a`.`saleID` AS `saleID`, `a`.`S_Date` AS `S_Date`, `a`.`S_Quantity` AS `S_Quantity`, `a`.`S_LegacyID` AS `S_LegacyID`, `b`.`ItemID` AS `ItemID`, `a`.`S_Discount` AS `S_Discount`, `a`.`S_UnitPrice` AS `S_UnitPrice`, `b`.`I_LegacyCode` AS `I_LegacyCode`, `b`.`I_Name` AS `I_Name`, `b`.`I_Discount` AS `I_Discount`, `b`.`I_UnitPrice` AS `I_UnitPrice`, `b`.`I_Image` AS `I_Image`, `b`.`I_Status` AS `I_Status`, `b`.`I_Stock` AS `I_Stock`, `b`.`I_Description` AS `I_Description`, `b`.`I_QRCode` AS `I_QRCode`, `b`.`I_QRPath` AS `I_QRPath`, `b`.`I_LastUpdate` AS `I_LastUpdate`, `b`.`I_Suggestion` AS `I_Suggestion`, `b`.`I_SuggestedPrice` AS `I_SuggestedPrice`, `c`.`CustomerID` AS `CustomerID`, `c`.`CustomerAddressID` AS `CustomerAddressID`, `c`.`C_Email` AS `C_Email`, `c`.`C_Mobile` AS `C_Mobile`, `c`.`C_Mobile2` AS `C_Mobile2`, `c`.`C_district` AS `C_district`, `c`.`C_status` AS `C_status`, `c`.`C_LegacyID` AS `C_LegacyID`, `d`.`CNNameID` AS `CNNameID`, `d`.`CN_FirstName` AS `CN_FirstName`, `d`.`CN_LastName` AS `CN_LastName`, `d`.`CN_MiddleName` AS `CN_MiddleName`, `d`.`CN_Suffix` AS `CN_Suffix`, `d`.`C_LFullName` AS `C_LFullName` FROM (((`sale` `a` join `item` `b` on(`a`.`ItemID` = `b`.`ItemID`)) join `customer` `c` on(`a`.`customerID` = `c`.`CustomerID`)) join `customername` `d` on(`c`.`CNNameID` = `d`.`CNNameID`)) ;

-- --------------------------------------------------------

--
-- Structure for view `vendorlist`
--
DROP TABLE IF EXISTS `vendorlist`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vendorlist`  AS SELECT `a`.`VendorID` AS `VendorID`, `a`.`VNameID` AS `VNameID`, `a`.`VendorAddressID` AS `VendorAddressID`, `a`.`V_Email` AS `V_Email`, `a`.`V_Mobile` AS `V_Mobile`, `a`.`V_Mobile2` AS `V_Mobile2`, `a`.`V_district` AS `V_district`, `a`.`V_status` AS `V_status`, `a`.`V_LegacyID` AS `V_LegacyID`, `b`.`VA_Street` AS `VA_Street`, `b`.`VA_Barangay` AS `VA_Barangay`, `b`.`VA_District` AS `VA_District`, `b`.`VA_City` AS `VA_City`, `b`.`VA_Province` AS `VA_Province`, `c`.`VN_FirstName` AS `VN_FirstName`, `c`.`VN_LastName` AS `VN_LastName`, `c`.`VN_MiddleName` AS `VN_MiddleName`, `c`.`VN_Suffix` AS `VN_Suffix`, `c`.`V_LFullName` AS `V_LFullName` FROM ((`vendor` `a` join `vendoraddress` `b` on(`a`.`VendorAddressID` = `b`.`VendorAddressID`)) join `vendorname` `c` on(`a`.`VNameID` = `c`.`VNameID`)) ;

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
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `customeraddress`
--
ALTER TABLE `customeraddress`
  MODIFY `CustomerAddressID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `customername`
--
ALTER TABLE `customername`
  MODIFY `CNNameID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT for table `item`
--
ALTER TABLE `item`
  MODIFY `ItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

--
-- AUTO_INCREMENT for table `purchase`
--
ALTER TABLE `purchase`
  MODIFY `purchaseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `sale`
--
ALTER TABLE `sale`
  MODIFY `saleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendor`
--
ALTER TABLE `vendor`
  MODIFY `VendorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vendoraddress`
--
ALTER TABLE `vendoraddress`
  MODIFY `VendorAddressID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `vendorname`
--
ALTER TABLE `vendorname`
  MODIFY `VNameID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
