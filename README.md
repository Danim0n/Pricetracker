# PriceTracker App

Aplicación móvil y web multiplataforma desarrollada en **Flutter** que se conecta a un backend en **FastAPI (Python)** y una base de datos **MySQL** para realizar el seguimiento, análisis e historial de fluctuaciones de precios de productos de e-commerce en tiempo real.

## Características del Proyecto

- **Dashboard Dinámico:** Visualización de productos en seguimiento mediante tarjetas interactivas alimentadas de forma asíncrona por la API.
- **Arquitectura Full-Stack:** Consumo de servicios REST con persistencia en MySQL relacional.
- **Gráficas de Evolución:** Análisis temporal del precio de los artículos mediante curvas dinámicas autoajustables.
- **Sistema de Alertas:** Formulario reactivo para la programación de objetivos de precio con persistencia automática en el backend.
- **Web Scraping Integrado:** Base de datos poblada de forma automatizada mediante scripts de raspado web independientes.

## Tecnologías Utilizadas

- **Frontend:** Flutter & Dart (Gestión de estados, renderizado nativo y Web, peticiones HTTP).
- **Backend:** Python, FastAPI, Uvicorn, Pydantic.
- **Base de Datos:** MySQL (Relaciones uno a muchos para históricos y alertas).