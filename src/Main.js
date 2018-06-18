exports._sendDocumentFromBuffer = function(bot, chatId, buffer, fileOptions) {
  return function() {
    return bot.sendDocument(chatId, buffer, {}, fileOptions);
  };
};
