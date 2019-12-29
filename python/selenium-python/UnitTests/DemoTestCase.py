from selenium_python_custom import *
from selenium_python_custom.constants import *

import unittest
from selenium import webdriver


class DemoTestCase(unittest.TestCase):

    def setChromeDriver(self):
        options = webdriver.ChromeOptions()
        options.add_experimental_option('excludeSwitches', ['enable-logging'])

        self.browser = webdriver.Chrome(
            executable_path=SELENIUM_DRIVER_PATH + r"chromedriver_79.0.3945.36.exe",
            options=options
        )

    def setFirefoxDriver(self):
        options = webdriver.FirefoxOptions()

        self.browser = webdriver.Firefox(
            executable_path=SELENIUM_DRIVER_PATH + r"geckodriver_0.26.0.exe",
            options=options
        )

    # Before each test
    def setUp(self):
        self.setChromeDriver()
        # self.addCleanup(self.browser.quit)

    # After each test
    def tearDown(self):
        # Any other action at the end of UnitTest
        self.browser.quit()

    def test_PageTitleExactly(self):
        self.browser.get('http://www.google.com')
        self.assertEqual('Google', self.browser.title)

    def test_PageTitleContains(self):
        self.browser.get('https://pypi.org/project/selenium/')
        self.assertIn('PyPI', self.browser.title)

    def test_ShouldFail(self):
        self.fail("Fail on purpose")
