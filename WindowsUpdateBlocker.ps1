Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Dark mode title bar API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class DarkMode {
    [DllImport("dwmapi.dll", PreserveSig = true)]
    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
    public const int DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
}
"@

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Update Blocker" Height="480" Width="500"
        WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize"
        Background="#181716">
    <Window.Resources>
        <SolidColorBrush x:Key="TabBg" Color="#1f1e1c"/>
        <SolidColorBrush x:Key="TabSelectedBg" Color="#181716"/>
        <SolidColorBrush x:Key="TextColor" Color="#E0E0E0"/>
        <SolidColorBrush x:Key="SubTextColor" Color="#888888"/>
        
        <Style TargetType="TabItem">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="Border" Background="{StaticResource TabBg}" BorderBrush="#3d3c3a" 
                                BorderThickness="1,1,1,0" CornerRadius="6,6,0,0" Padding="15,8" Margin="2,0,0,0">
                            <ContentPresenter ContentSource="Header"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="{StaticResource TabSelectedBg}"/>
                                <Setter TargetName="Border" Property="BorderBrush" Value="#4CAF50"/>
                                <Setter TargetName="Border" Property="BorderThickness" Value="1,2,1,0"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#2d2c2a"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <TabControl Background="#181716" BorderThickness="0" Margin="0,10,0,0">
        <!-- Control Tab -->
        <TabItem>
            <TabItem.Header>
                <TextBlock Text="Control" Foreground="{StaticResource TextColor}" FontWeight="SemiBold"/>
            </TabItem.Header>
            <Grid Background="#181716">
                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center" Margin="30">
                    
                    <!-- Status Card -->
                    <Border Background="#1f1e1c" CornerRadius="10" Padding="25" Margin="0,0,0,25">
                        <StackPanel>
                            <TextBlock Text="Current Status" Foreground="#888888" FontSize="12" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                            <Border x:Name="StatusBorder" CornerRadius="8" Padding="20,12" HorizontalAlignment="Center" Background="#1a2a1a">
                                <StackPanel Orientation="Horizontal">
                                    <Ellipse x:Name="StatusDot" Width="12" Height="12" Margin="0,0,10,0" Fill="#4CAF50"/>
                                    <TextBlock x:Name="StatusText" FontSize="16" FontWeight="Bold" Foreground="#E0E0E0" Text="CHECKING..."/>
                                </StackPanel>
                            </Border>
                            <TextBlock x:Name="StatusDescription" Foreground="#888888" FontSize="11" HorizontalAlignment="Center" 
                                       Margin="0,12,0,0" TextWrapping="Wrap" TextAlignment="Center" MaxWidth="300"/>
                        </StackPanel>
                    </Border>
                    
                    <!-- Buttons -->
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="15"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        
                        <Button x:Name="PauseBtn" Grid.Column="0" Content="PAUSE UPDATES" Height="50"/>
                        <Button x:Name="ResumeBtn" Grid.Column="2" Content="RESUME UPDATES" Height="50"/>
                    </Grid>
                    
                    <!-- Message -->
                    <Border x:Name="MessageBorder" Background="#2d2c2a" CornerRadius="6" Padding="15,10" Margin="0,20,0,0" Visibility="Collapsed">
                        <TextBlock x:Name="MessageText" Foreground="#E0E0E0" FontSize="12" TextWrapping="Wrap" TextAlignment="Center"/>
                    </Border>
                </StackPanel>
            </Grid>
        </TabItem>
        
        <!-- About Tab -->
        <TabItem>
            <TabItem.Header>
                <TextBlock Text="About" Foreground="{StaticResource TextColor}" FontWeight="SemiBold"/>
            </TabItem.Header>
            <Grid Background="#181716">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center" Margin="30">
                        <Border Background="#1f1e1c" CornerRadius="10" Padding="30">
                            <StackPanel>
                                <!-- App Logo -->
                                <Border Background="#2E7D32" CornerRadius="25" Width="50" Height="50" HorizontalAlignment="Center" Margin="0,0,0,15">
                                    <TextBlock Text="S" FontSize="24" FontWeight="Bold" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                
                                <!-- App Name -->
                                <TextBlock Text="Windows Update Blocker" Foreground="#E0E0E0" FontSize="22" FontWeight="Bold" HorizontalAlignment="Center"/>
                                
                                <!-- Version -->
                                <TextBlock Text="Version 1.0.0" Foreground="#888888" FontSize="12" HorizontalAlignment="Center" Margin="0,5,0,20"/>
                                
                                <Border Background="#3d3c3a" Height="1" Margin="0,0,0,20"/>
                                
                                <!-- Description -->
                                <TextBlock Foreground="#AAAAAA" FontSize="13" TextWrapping="Wrap" TextAlignment="Center" MaxWidth="350" LineHeight="22">
                                    A simple utility to pause or resume Windows Updates by modifying registry settings. Updates can be paused indefinitely until you choose to resume them.
                                </TextBlock>
                                
                                <Border Background="#3d3c3a" Height="1" Margin="0,20"/>
                                
                                <!-- How it works -->
                                <TextBlock Text="How it works:" Foreground="#E0E0E0" FontSize="14" FontWeight="SemiBold" Margin="0,0,0,10"/>
                                
                                <TextBlock Foreground="#888888" FontSize="12" TextWrapping="Wrap" MaxWidth="350" LineHeight="20" Text=" Pause: Sets update pause dates to year 2099&#x0a; Resume: Removes the pause registry entries&#x0a; Requires Administrator privileges&#x0a; Modifies: HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"/>
                                
                                <Border Background="#3d3c3a" Height="1" Margin="0,20"/>
                                
                                <!-- Footer -->
                                <TextBlock Text="2026 - Use at your own risk" Foreground="#666666" FontSize="11" HorizontalAlignment="Center"/>
                                <TextBlock Text="github.com/GrimSQL/WindowsUpdateBlocker" Foreground="#4CAF50" FontSize="11" HorizontalAlignment="Center" Margin="0,5,0,0"/>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </Grid>
        </TabItem>
    </TabControl>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$StatusBorder = $window.FindName("StatusBorder")
$StatusDot = $window.FindName("StatusDot")
$StatusText = $window.FindName("StatusText")
$StatusDescription = $window.FindName("StatusDescription")
$PauseBtn = $window.FindName("PauseBtn")
$ResumeBtn = $window.FindName("ResumeBtn")
$MessageBorder = $window.FindName("MessageBorder")
$MessageText = $window.FindName("MessageText")

# Style buttons
foreach ($btn in @($PauseBtn, $ResumeBtn)) {
    $btn.Foreground = [System.Windows.Media.Brushes]::White
    $btn.FontSize = 14
    $btn.FontWeight = "SemiBold"
    $btn.BorderThickness = [System.Windows.Thickness]::new(1)
    $btn.Cursor = [System.Windows.Input.Cursors]::Hand
}
$PauseBtn.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(139,0,0))
$PauseBtn.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(165,42,42))
$ResumeBtn.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(46,125,50))
$ResumeBtn.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(56,142,60))

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

function Test-UpdatesPaused {
    try {
        $value = Get-ItemProperty -Path $RegistryPath -Name "PauseUpdatesExpiryTime" -ErrorAction SilentlyContinue
        return ($null -ne $value.PauseUpdatesExpiryTime -and $value.PauseUpdatesExpiryTime -ne "")
    } catch { return $false }
}

function Update-Status {
    $isPaused = Test-UpdatesPaused
    if ($isPaused) {
        $StatusText.Text = "UPDATES PAUSED"
        $StatusDot.Fill = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(244,67,54))
        $StatusBorder.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(42,26,26))
        $StatusDescription.Text = "Windows Updates are currently blocked.`nYour system will not download or install updates."
        $PauseBtn.Opacity = 0.6
        $ResumeBtn.Opacity = 1.0
    } else {
        $StatusText.Text = "UPDATES ACTIVE"
        $StatusDot.Fill = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(76,175,80))
        $StatusBorder.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(26,42,26))
        $StatusDescription.Text = "Windows Updates are running normally.`nYour system will receive updates as usual."
        $PauseBtn.Opacity = 1.0
        $ResumeBtn.Opacity = 0.6
    }
    $MessageBorder.Visibility = "Collapsed"
}

function Show-Message($msg, $isError) {
    $MessageText.Text = $msg
    if ($isError) {
        $MessageBorder.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(58,32,32))
    } else {
        $MessageBorder.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(32,58,32))
    }
    $MessageBorder.Visibility = "Visible"
}

$PauseBtn.Add_Click({
    if (Test-UpdatesPaused) {
        Show-Message "Updates are already paused! No action needed." $true
        return
    }
    try {
        Set-ItemProperty -Path $RegistryPath -Name "PauseUpdatesExpiryTime" -Value "2099-11-11T16:38:59Z" -Type String -Force
        Set-ItemProperty -Path $RegistryPath -Name "PauseFeatureUpdatesEndTime" -Value "2099-11-11T11:11:11Z" -Type String -Force
        Set-ItemProperty -Path $RegistryPath -Name "PauseQualityUpdatesEndTime" -Value "2099-11-11T11:11:11Z" -Type String -Force
        Set-ItemProperty -Path $RegistryPath -Name "PauseUpdatesStartTime" -Value "1990-11-22T15:09:05Z" -Type String -Force
        Set-ItemProperty -Path $RegistryPath -Name "PauseFeatureUpdatesStartTime" -Value "1990-11-22T15:09:05Z" -Type String -Force
        Set-ItemProperty -Path $RegistryPath -Name "PauseQualityUpdatesStartTime" -Value "1990-11-22T15:09:05Z" -Type String -Force
        Update-Status
        Show-Message "Windows Updates have been paused successfully!" $false
    } catch {
        Show-Message "Error: Make sure you run as Administrator. $_" $true
    }
})

$ResumeBtn.Add_Click({
    if (-not (Test-UpdatesPaused)) {
        Show-Message "Updates are already active! No action needed." $true
        return
    }
    try {
        $props = @("PauseUpdatesExpiryTime","PauseFeatureUpdatesEndTime","PauseQualityUpdatesEndTime",
                   "PauseUpdatesStartTime","PauseFeatureUpdatesStartTime","PauseQualityUpdatesStartTime")
        foreach ($p in $props) {
            Remove-ItemProperty -Path $RegistryPath -Name $p -ErrorAction SilentlyContinue
        }
        Update-Status
        Show-Message "Windows Updates have been resumed successfully!" $false
    } catch {
        Show-Message "Error: Make sure you run as Administrator. $_" $true
    }
})

# Apply dark title bar on load
$window.Add_Loaded({
    $hwnd = [System.Windows.Interop.WindowInteropHelper]::new($window).Handle
    $dark = 1
    [DarkMode]::DwmSetWindowAttribute($hwnd, [DarkMode]::DWMWA_USE_IMMERSIVE_DARK_MODE, [ref]$dark, 4)
    Update-Status
})

$window.ShowDialog() | Out-Null
