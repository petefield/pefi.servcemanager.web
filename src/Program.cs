using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using pefi.servicemanager.web;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddBlazorBootstrap();


builder.Services.AddHttpClient<ServiceManagerClient>(c => c.BaseAddress = new Uri("http://192.168.0.42:5550"));



await builder.Build().RunAsync();
