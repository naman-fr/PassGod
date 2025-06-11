export class Constants {
    static readonly appName: string = "PASSGOD";
    static readonly apiBaseUrl: string = "http://localhost:8000/api/v1"; // Your FastAPI backend URL
    static readonly tokenKey: string = "passgod_access_token";
    static readonly userKey: string = "passgod_user_data"; // For storing user data if needed
}