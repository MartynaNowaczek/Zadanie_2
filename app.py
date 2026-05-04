from flask import Flask, render_template_string, request
from datetime import datetime
import requests
import logging

AUTHOR = "Martyna Nowaczek"
PORT = 8080

app = Flask(__name__)

html = """
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Weather App</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #74ebd5, #9face6);
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .card {
            background: white;
            padding: 35px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            width: 420px;
            text-align: center;
        }

        h1 {
            margin-top: 0;
            color: #333;
        }

        input, button {
            width: 100%;
            box-sizing: border-box;
            padding: 12px;
            margin-top: 12px;
            border-radius: 10px;
            border: 1px solid #ccc;
            font-size: 16px;
        }

        button {
            background: #4f46e5;
            color: white;
            border: none;
            cursor: pointer;
            font-weight: bold;
        }

        button:hover {
            background: #3730a3;
        }

        .weather {
            margin-top: 25px;
            padding: 20px;
            background: #f3f4f6;
            border-radius: 15px;
        }

        .temp {
            font-size: 42px;
            font-weight: bold;
            color: #4f46e5;
        }

        .info {
            color: #555;
            margin: 8px 0;
        }

        .error {
            margin-top: 20px;
            color: #b91c1c;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="card">
        <h1>Aktualna pogoda</h1>

        <form method="GET">
            <input 
                type="text" 
                name="city" 
                placeholder="Wpisz miasto, np. Warszawa" 
                value="{{ query or '' }}"
                required
            >
            <button type="submit">Sprawdź pogodę</button>
        </form>

        {% if error %}
            <p class="error">{{ error }}</p>
        {% endif %}

        {% if weather %}
            <div class="weather">
                <h2>{{ city }}</h2>
                <div class="temp">{{ weather["temperature"] }}°C</div>
                <p class="info">Wiatr: {{ weather["windspeed"] }} km/h</p>
                <p class="info">Kod pogody: {{ weather["weathercode"] }}</p>
            </div>
        {% endif %}
    </div>
</body>
</html>
"""


def get_coordinates(city):
    url = "https://geocoding-api.open-meteo.com/v1/search"

    params = {
        "name": city,
        "count": 1,
        "language": "pl",
        "format": "json"
    }

    response = requests.get(url, params=params, timeout=5)
    data = response.json()

    if "results" not in data or len(data["results"]) == 0:
        return None

    result = data["results"][0]

    return {
        "name": result["name"],
        "country": result.get("country", ""),
        "lat": result["latitude"],
        "lon": result["longitude"]
    }


def get_weather(lat, lon):
    url = "https://api.open-meteo.com/v1/forecast"

    params = {
        "latitude": lat,
        "longitude": lon,
        "current_weather": "true"
    }

    response = requests.get(url, params=params, timeout=5)
    data = response.json()

    return data.get("current_weather")


@app.route("/")
def index():
    query = request.args.get("city")
    weather = None
    city_name = None
    error = None

    if query:
        location = get_coordinates(query)

        if location is None:
            error = "Nie znaleziono podanego miasta."
        else:
            weather = get_weather(location["lat"], location["lon"])
            city_name = f'{location["name"]}, {location["country"]}'

            if weather is None:
                error = "Nie udało się pobrać pogody."

    return render_template_string(
        html,
        query=query,
        city=city_name,
        weather=weather,
        error=error
    )


@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    logging.info("=== START APLIKACJI ===")
    logging.info(f"Data uruchomienia: {datetime.now().isoformat()}")
    logging.info(f"Autor: {AUTHOR}")
    logging.info(f"Port TCP: {PORT}")
    logging.info("======================")

    app.run(host="0.0.0.0", port=PORT)