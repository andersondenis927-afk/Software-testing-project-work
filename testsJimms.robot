
*** Settings ***
Library    SeleniumLibrary
Library    Collections
Library    String
Library    OperatingSystem

Suite Setup    Open Jimms
Suite Teardown    Close All Browsers

*** Variables ***
${url}    https://www.jimms.fi/
${browser}    chrome
${word}    ps5
${timeout}    20s
${screenshots}    ${CURDIR}${/}screenshots
${search_field}    xpath=//input[contains(@placeholder,'Hae tuotteista') or contains(@aria-label,'Hae tuotteista') or @type='search']
${category_links}    xpath=//a[contains(@href,'/Product/List/')]
${product_links}    xpath=//a[contains(@href,'/Product/Show/')]
${first_product}    xpath=(//a[contains(@href,'/Product/Show/')])[1]
${cart_icon}    xpath=(//a[contains(@href,'cart') or contains(@href,'Cart') or contains(@href,'ostoskori') or contains(@aria-label,'Ostoskori') or contains(@title,'Ostoskori')])[1]
${add_to_cart}    xpath=//*[self::a or self::button or self::input][contains(normalize-space(.),'Lisää koriin') or @value='Lisää koriin' or @aria-label='Lisää koriin']
${body}    xpath=//body

*** Keywords ***
Open Jimms
    Create Directory    ${screenshots}
    Open Browser    ${url}    ${browser}
    Maximize Browser Window
    Wait Until Page Contains Element    ${body}    ${timeout}
    Sleep    3s

Get Category Links
    Go To    ${url}
    Sleep    3s
    ${elements}=    Get WebElements    ${category_links}
    ${links}=    Create List
    FOR    ${element}    IN    @{elements}
        ${href}=    Get Element Attribute    ${element}    href
        IF    $href
            Append To List    ${links}    ${href}
        END
    END
    ${unique}=    Remove Duplicates    ${links}
    RETURN    ${unique}

Search For Product
    [Arguments]    ${keyword}
    Go To    ${url}
    Wait Until Element Is Visible    ${search_field}    ${timeout}
    Clear Element Text    ${search_field}
    Input Text    ${search_field}    ${keyword}
    Press Keys    ${search_field}    ENTER
    Sleep    4s
    Wait Until Page Contains Element    ${body}    ${timeout}

Open First Product
    Wait Until Element Is Visible    ${first_product}    ${timeout}
    Click Element    ${first_product}
    Sleep    3s
    Wait Until Page Contains Element    ${body}    ${timeout}

*** Test Cases ***
Check Categories
    ${links}=    Get Category Links
    ${length}=    Get Length    ${links}
    Should Be True    ${length} > 0
    ${checked}=    Set Variable    0
    FOR    ${link}    IN    @{links}
        Go To    ${link}
        Wait Until Page Contains Element    ${body}    ${timeout}
        ${text}=    Get Text    ${body}
        Should Not Be Empty    ${text}
        ${checked}=    Evaluate    ${checked} + 1
        Exit For Loop If    ${checked} >= 5
    END

Search Product
    Search For Product    ${word}
    Wait Until Element Is Visible    ${first_product}    ${timeout}
    Capture Element Screenshot    ${first_product}    ${screenshots}${/}first_product.png
    Wait Until Element Is Visible    ${cart_icon}    ${timeout}
    Capture Element Screenshot    ${cart_icon}    ${screenshots}${/}cart_icon.png
    File Should Exist    ${screenshots}${/}first_product.png
    File Should Exist    ${screenshots}${/}cart_icon.png

Open Product
    Search For Product    ${word}
    ${results_url}=    Get Location
    Open First Product
    ${product_url}=    Get Location
    Should Not Be Equal    ${results_url}    ${product_url}
    ${text}=    Get Text    ${body}
    ${text}=    Convert To Lower Case    ${text}
    ${keyword}=    Convert To Lower Case    ${word}
    Should Contain    ${text}    ${keyword}
    Capture Page Screenshot    ${screenshots}${/}product_page.png

Check Add To Cart
    Search For Product    ${word}
    Open First Product
    Wait Until Element Is Visible    ${add_to_cart}    ${timeout}
    Element Should Be Enabled    ${add_to_cart}

Add To Cart
    Search For Product    ${word}
    Open First Product
    Wait Until Element Is Visible    ${add_to_cart}    ${timeout}
    Click Element    ${add_to_cart}
    Sleep    3s
    Capture Page Screenshot    ${screenshots}${/}after_add_click.png
    Go To    ${url}
    Sleep    2s
    Wait Until Element Is Visible    ${cart_icon}    ${timeout}
    Click Element    ${cart_icon}
    Sleep    3s
    ${cart_text}=    Get Text    ${body}
    Should Not Be Empty    ${cart_text}
    Capture Page Screenshot    ${screenshots}${/}cart_page.png
