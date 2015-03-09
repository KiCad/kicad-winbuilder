import wx
import wx.py.crust

app = wx.App(redirect=True)
top = wx.Frame(None, title="Hello World", size=(300,200))
top.Show()
crustFrame = wx.py.crust.CrustFrame( parent = top )
crustFrame.Show()
app.MainLoop()
