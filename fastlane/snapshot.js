#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

UIALogger.logStart("Test Automation");

captureLocalizedScreenshot("0-LandingScreen")
target.delay(3)
captureLocalizedScreenshot("1-LogInScreen")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
target.delay(3) // UI Automation Bug

// login now with xinjiang.shao+prephero@exactsports.com / 123456
target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].setValue("xinjiang.shao+prephero@exactsports.com");
target.frontMostApp().mainWindow().scrollViews()[0].secureTextFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].secureTextFields()[0].setValue("123456");
target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Login Now"].tap();

// Capture View
target.delay(3)
captureLocalizedScreenshot("2-CapturePortraitScreen")
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);
target.delay(3)
captureLocalizedScreenshot("3-CaptureLandscapeScreen")

target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
target.delay(3)

// Highlight Videos
target.frontMostApp().tabBar().buttons()["Highlights"].tap();
target.delay(3)
captureLocalizedScreenshot("4-HighlightVideosScreen")

// More Option
target.frontMostApp().tabBar().buttons()["More"].tap();
target.delay(3)
captureLocalizedScreenshot("5-MoreScreen")

target.frontMostApp().mainWindow().tableViews()[0].cells()["PrepHero Website"].staticTexts()["PrepHero Website"].scrollToVisible();
target.frontMostApp().mainWindow().tableViews()[0].cells()["Log Out"].tap();

target.delay(1)
UIATarget.onAlert = function onAlert(alert){
    var title = alert.name();
    UIALogger.logWarning("Alert with title " + title + " encountered!");
    target.frontMostApp().alert().buttons()["OK"].tap();
    return false; // use default handler
}
