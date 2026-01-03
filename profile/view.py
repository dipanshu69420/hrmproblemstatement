from dash import html

def profile_card(title, data_dict):
    return html.Div(
        style={
            "border": "1px solid #ddd",
            "padding": "10px",
            "borderRadius": "6px",
            "marginBottom": "10px",
        },
        children=[
            html.H4(title),
            html.Ul([
                html.Li(f"{k}: {v}") for k, v in data_dict.items()
            ])
        ]
    )


def employee_profile_layout(profile):
    if not profile:
        return html.Div("Select an employee to view profile")

    return html.Div(
        style={"display": "flex", "gap": "20px"},
        children=[
            html.Div(
                style={"width": "25%"},
                children=[
                    html.Img(
                        src=profile["profile_pic"],
                        style={"width": "100%", "borderRadius": "8px"}
                    ),
                ]
            ),
            html.Div(
                style={"flex": 1},
                children=[
                    profile_card("Personal Details", profile["personal"]),
                    profile_card("Job Details", profile["job"]),
                    profile_card("Salary Structure", profile["salary"]),
                    profile_card(
                        "Documents",
                        {str(i+1): d for i, d in enumerate(profile["documents"])}
                    )
                ]
            )
        ]
    )
