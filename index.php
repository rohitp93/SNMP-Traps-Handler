<!DOCTYPE html>
<html>
<head>
<h2 align = "center">SNMP Trap Handler</h2>
<title>Assignment 3</title>
</head>

<?php
	include "db.php";

	$conn = mysqli_connect($host, $username, $password, $database, $port);

	if (!$conn)
	{
	   die("Connection failed: " . mysqli_connect_error());
	}
	
	mysqli_select_db($conn,"$database");	

	$create1 = mysqli_query($conn,"CREATE TABLE IF NOT EXISTS Traps (fqdn varchar (255) NOT NULL, cur_st int (11) NOT NULL, pre_st int DEFAULT 0, cur_time int NOT NULL, pre_time int DEFAULT 0, PRIMARY KEY (fqdn)) ENGINE=InnoDB DEFAULT CHARSET= latin1;");
	mysqli_query($conn,$creat1);

	$create2 = mysqli_query($conn,"CREATE TABLE IF NOT EXISTS Manager (id int (11) NOT NULL, IP tinytext NOT NULL, PORT int (11) NOT NULL, COMMUNITY tinytext NOT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET= latin1");
	mysqli_query($conn,$creat2);	

	$sql = "INSERT IGNORE INTO Manager (id) VALUES ('1')";
	mysqli_query($conn,$sql);

?>

<form action="index.php" method="POST">
<fieldset>
<legend>Device Configuration</legend>
IP<input type="text" name="ip">&ensp;
PORT<input type="text" name="port">&ensp;
COMMUNITY<input type="text" name="community">&ensp;
<input type="submit" name="manager" value="Send"><br>
</fieldset>
</form><br>

<?php
$ip = $_POST['ip'];
$ports = $_POST['port'];
$com = $_POST['community'];

	if(isset($_REQUEST['manager']))  
	{
		$sql = "UPDATE Manager SET IP='$ip',PORT='$ports',COMMUNITY='$com'";
		mysqli_query($conn,$sql);
	}

?>
<table style = "width: 70%; text-align: center; border: 1px solid black;" align="center">
<caption><h3>Manager</h3></caption>
<tr>
<th>IP</th>
<th>PORT</th>
<th>COMMUNITY</th>
</tr>
<?php
$result2 = mysqli_query($conn,"SELECT * FROM Manager");
       
while($row = mysqli_fetch_array($result2)) 
{
?>
<tr>
<td><?php echo $row["IP"]; ?></td>
<td><?php echo $row["PORT"]; ?></td>
<td><?php echo $row["COMMUNITY"]; }?></td>
</tr>

<table style = "width: 70%; text-align: center; border: 1px solid black;" align="center">
<caption><h3>Agents</h3></caption>
<tr>
<th>FQDN</th>
<th>Current Status</th>
<th>Previous Status</th>
<th>Current Time</th>
<th>Previous Time</th>
</tr>

<?php
$result = mysqli_query($conn,"SELECT * FROM Traps"); 

while($row = mysqli_fetch_array($result)) 
{

?>
<tr>
<td><?php echo $row["fqdn"]; ?></td>
<td><?php echo $row["cur_st"]; ?></td>
<td><?php echo $row["pre_st"]; ?></td>
<td><?php echo $row["cur_time"]; ?></td>
<td><?php echo $row["pre_time"]; }?></td>
</tr>
</table>
<br><br><br><footer><center>Rohit Pothuraju</center></footer>



