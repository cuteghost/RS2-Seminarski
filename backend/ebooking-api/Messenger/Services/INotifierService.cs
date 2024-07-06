using Models.Domain;

namespace Messenger;

public interface INotifierService
{
    public Task Notify(WelcomeMessage welcomeMessage);
}
