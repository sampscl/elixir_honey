import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Typography from '@material-ui/core/Typography';

import { Device } from '../types/types'
import { DeviceProps } from '../types/comp_props'

const useStyles = makeStyles({
  root: {
    minWidth: 275,
  },
  bullet: {
    display: 'inline-block',
    margin: '0 2px',
    transform: 'scale(0.8)',
  },
  title: {
    fontSize: 14,
  },
  pos: {
    marginBottom: 12,
  },
});

function type_string(device: Device): String {
  switch(device.type) {
    case "ip":      return "camera"
    case "rtl-sdr": return "radio"
    default:        return "unknown"
  }
}

function device_details(device: Device) {
  switch(device.type) {
    case "rtl-sdr": 
    return <Typography variant="body2" component="p">
      Radio device
    </Typography>

    case "ip": 
    return <Typography variant="body2" component="p">
      IP Camera device
    </Typography>

    default:
    return <Typography variant="body2" component="p">
      Unknown device
    </Typography>
  }
}

export default function DeviceComp({device}: DeviceProps) {
  const classes = useStyles();

  return (
    <Card className={classes.root}>
      <CardContent>
        <Typography className={classes.title} color="textSecondary" gutterBottom>
          { device.name } ({type_string(device)})
        </Typography>
        { device_details(device) }
      </CardContent>
      <CardActions>
      </CardActions>
    </Card>
  );
}
