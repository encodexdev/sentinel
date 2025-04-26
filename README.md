<div align="center" style="padding-bottom: 16px;">
  <img src="docs/demo/app_icon.png" alt="App Icon" width="100" style="border-radius: 16px;" />
  <h1>Sentinel</h1>
  <p>A secure, AI-guided incident reporting and visualization app for private security teams.</p>
</div>

## Demo

<!-- Use `docs/demo/` for image and gif demo files -->
<p align="center">
  <img src="docs/demo/home.png" alt="Home Screen" width="200" style="border-radius: 8px;" />
  <img src="docs/demo/chat.png" alt="Chat Interface" width="200" style="border-radius: 8px;" />
  <img src="docs/demo/map.png" alt="Map View" width="200" style="border-radius: 8px;" />
  <img src="docs/demo/profile.png" alt="Profile & Settings" width="200" style="border-radius: 8px;" />
</p>

---

> Screenshots above demonstrate the app’s key UI flows:
>
> - **Home**: Overview and quick actions.
> - **Report**: Step-by-step guided incident reporting chat.
> - **Map**: Animated, interactive incident pins.
> - **Profile**: User settings and appearance customization.

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/encodexdev/sentinel.git
   cd sentinel
   ```

2. **Copy and configure environment variables**

   ```bash
   cp .env.example .env
   # Open .env and set your OPENAI_API_KEY
   ```

3. **Open in Xcode**

   ```bash
   open Sentinel.xcodeproj
   ```

4. **Build and Run**
   - Target: iOS 15.0 or later
   - Scheme: `Sentinel`
