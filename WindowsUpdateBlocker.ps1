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
        Title="Windows Update Blocker" Height="420" Width="480"
        WindowStartupLocation="CenterScreen" ResizeMode="CanMinimize"
        Background="#181716">
    <Window.Resources>
        <Style x:Key="DarkButton" TargetType="Button">
            <Setter Property="Background" Value="#2d2c2a"/>
            <Setter Property="Foreground" Value="#E0E0E0"/>
            <Setter Property="BorderBrush" Value="#3d3c3a"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="20,12"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#3d3c3a"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    
    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center">
            <!-- Title -->
            <TextBlock Text="Windows Update Blocker" Foreground="#E0E0E0" FontSize="24" FontWeight="Bold" 
                       HorizontalAlignment="Center" Margin="0,0,0,30"/>
            
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
                
                <Button x:Name="PauseBtn" Grid.Column="0" Content="PAUSE UPDATES" Height="50" Background="#8B0000" BorderBrush="#A52A2A"/>
                <Button x:Name="ResumeBtn" Grid.Column="2" Content="RESUME UPDATES" Height="50" Background="#2E7D32" BorderBrush="#388E3C"/>
            </Grid>
            
            <!-- Message -->
            <Border x:Name="MessageBorder" Background="#2d2c2a" CornerRadius="6" Padding="15,10" Margin="0,20,0,0" Visibility="Collapsed">
                <TextBlock x:Name="MessageText" Foreground="#E0E0E0" FontSize="12" TextWrapping="Wrap" TextAlignment="Center"/>
            </Border>
            
            <!-- About -->
            <TextBlock Text="v1.0 - Modifies Windows Update registry settings" Foreground="#555555" FontSize="10" 
                       HorizontalAlignment="Center" Margin="0,25,0,0"/>
        </StackPanel>
    </Grid>
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

# Apply button styles
foreach ($btn in @($PauseBtn, $ResumeBtn)) {
    $btn.Foreground = [System.Windows.Media.Brushes]::White
    $btn.FontSize = 14
    $btn.FontWeight = "SemiBold"
    $btn.BorderThickness = [System.Windows.Thickness]::new(1)
    $btn.Cursor = [System.Windows.Input.Cursors]::Hand
}

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
        $StatusDot.Fill = [System.Windows.Media.Brushes]::Red
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
