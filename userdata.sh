#!/bin/bash
# ============================================================
# EC2 User Data Script — 3-Tier Web App (Web / App Tier)
# Installs Apache, PHP, and connects to RDS MySQL backend
# ============================================================

set -e  # Exit on any error

# ── 1. Update OS & install packages ─────────────────────────
echo "[INFO] Updating system packages..."
yum update -y

echo "[INFO] Installing Apache, PHP, and MySQL client..."
yum install -y httpd php php-mysqlnd mysql

# ── 2. Start & enable Apache ─────────────────────────────────
echo "[INFO] Starting Apache web server..."
systemctl start httpd
systemctl enable httpd

# ── 3. Set permissions ───────────────────────────────────────
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# ── 4. Deploy sample web page ────────────────────────────────
echo "[INFO] Deploying sample application page..."
cat > /var/www/html/index.php << 'EOF'
<?php
// ── DB Configuration (replace with your RDS endpoint) ──────
$db_host = getenv('DB_HOST') ?: 'your-rds-endpoint.rds.amazonaws.com';
$db_name = getenv('DB_NAME') ?: 'appdb';
$db_user = getenv('DB_USER') ?: 'admin';
$db_pass = getenv('DB_PASS') ?: 'yourpassword';

$connection_status = "Not Connected";
$connection_color  = "#e74c3c";

// ── Try connecting to RDS ───────────────────────────────────
try {
    $conn = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $connection_status = "✅ Connected to RDS MySQL";
    $connection_color  = "#27ae60";
} catch (PDOException $e) {
    $connection_status = "❌ DB Connection Failed: " . $e->getMessage();
}

$instance_id   = shell_exec('curl -s http://169.254.169.254/latest/meta-data/instance-id');
$az            = shell_exec('curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone');
$private_ip    = shell_exec('curl -s http://169.254.169.254/latest/meta-data/local-ipv4');
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>AWS 3-Tier Web App</title>
  <style>
    body { font-family: Arial, sans-serif; background: #f0f2f5; margin: 0; padding: 40px; }
    .card { background: white; border-radius: 10px; padding: 30px; max-width: 600px;
            margin: auto; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
    h1 { color: #FF9900; }
    .badge { display: inline-block; padding: 6px 14px; border-radius: 20px;
             color: white; font-weight: bold; margin: 4px 0; }
    .info { background: #3498db; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    td { padding: 10px; border-bottom: 1px solid #eee; }
    td:first-child { font-weight: bold; color: #555; width: 40%; }
  </style>
</head>
<body>
  <div class="card">
    <h1>☁️ AWS 3-Tier Web App</h1>
    <p>Production-grade architecture on AWS</p>
    <span class="badge" style="background: <?= $connection_color ?>"><?= $connection_status ?></span>
    <table>
      <tr><td>Instance ID</td><td><?= htmlspecialchars($instance_id) ?></td></tr>
      <tr><td>Availability Zone</td><td><?= htmlspecialchars($az) ?></td></tr>
      <tr><td>Private IP</td><td><?= htmlspecialchars($private_ip) ?></td></tr>
      <tr><td>Timestamp</td><td><?= date('Y-m-d H:i:s') ?> UTC</td></tr>
    </table>
  </div>
</body>
</html>
EOF

echo "[INFO] Web server setup complete!"
echo "[INFO] Access the app via the Load Balancer DNS."
