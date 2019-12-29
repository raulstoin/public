from selenium_python_custom import *
from selenium_python_custom.constants import *

import pytest


@pytest.mark.nondestructive
def test_nondestructive(selenium):
    selenium.get('http://www.google.com')
    elem = selenium.find_element_by_id("hplogo")


@pytest.mark.nondestructive
def test_PageTitleExactly(selenium):
    selenium.get('http://www.google.com')
    assert('Google' == selenium.title)


@pytest.mark.nondestructive
def test_PageTitleContains(selenium):
    selenium.get('https://pypi.org/project/selenium/')
    assert(selenium.title.find("PyPI") != -1)


# @pytest.mark.nondestructive
# def test_ShouldFail(selenium):
    # pytest.fail("Fail on purpose")
