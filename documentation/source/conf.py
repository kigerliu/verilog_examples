# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Verilog Design Examples'
copyright = '2023, Kiger Liu'
author = 'Kiger Liu'
release = '1.0'
language = 'en'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = []

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_theme = 'alabaster'
# html_static_path = ['_static']

html_theme = 'classic'
# html_logo = 'logo_test.png'
html_theme_options = {
    "stickysidebar"     : "true", # 侧边栏是否固定而不随页面滚动
    "sidebarwidth"      : "300",
    "collapsiblesidebar": "false", # 侧边栏是否可以隐藏
    "body_min_width"    : 0,
    "body_max_width"    : "none",
    "footerbgcolor"     : "#0085bd", # 底部栏背景颜色
    "footertextcolor"   : "#ffffff",
    "sidebarbgcolor"    : "#43a0dc", # 侧边栏背景颜色
    "sidebarbtncolor"   : "#ffffff",
    "sidebartextcolor"  : "#ffffff",
    "sidebarlinkcolor"  : "#ffffff",
    "relbarbgcolor"     : "#0085bd",
    "relbartextcolor"   : "#ffffff",
    "relbarlinkcolor"   : "#ffffff"
}

extensions = [
    'sphinx_copybutton',
    'recommonmark',
    'sphinx_markdown_tables'
]

# html_theme = 'sphinx_rtd_theme'
# html_logo = 'logo_test.png'
# html_theme_options = {
#     'analytics_id': 'G-XXXXXXXXXX',  #  Provided by Google in your dashboard
#     'analytics_anonymize_ip': False,
#     'logo_only': False,
#     'display_version': True,
#     'prev_next_buttons_location': 'bottom',
#     'style_external_links': False,
#     'vcs_pageview_mode': '',
#     'style_nav_header_background': '#2980B9',
#     # Toc options
#     'collapse_navigation': True,
#     'sticky_navigation': True,
#     'navigation_depth': 4,
#     'includehidden': True,
#     'titles_only': False
# }